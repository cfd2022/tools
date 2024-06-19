#!/bin/bash

# Define a function to print in red
print_red() {
  local text="$1"
  echo -e "\033[31m${text}\033[0m"
}

# Define a function to print in green
print_green() {
  local text="$1"
  echo -e "\033[32m${text}\033[0m"
}

# Function to disable swap and permanently disable it
disable_swap() {
  print_red "Swap is enabled, disabling..."

  # Running swapoff -a and swapon -a together refreshes swap, transferring data back to memory and clearing swap data. Do not omit swappiness setting and only execute swapoff -a; otherwise, swap will automatically re-enable after reboot, making the operation ineffective.
  # The sysctl -p command makes the configuration effective without rebooting.
  grep -q "vm.swappiness = 0" /etc/sysctl.conf || echo "vm.swappiness = 0" >> /etc/sysctl.conf
  swapoff -a && swapon -a
  sysctl -p
  print_green "Swap has been disabled and permanently disabled"
}

# Function to check swap status and disable swap if necessary
check_and_disable_swap() {
  # Check if vm.swappiness is already set to 0
  if grep -q "vm.swappiness = 0" /etc/sysctl.conf; then
    print_green "vm.swappiness is already set to 0"
  else
    disable_swap
  fi

  ulimit_value=$(ulimit -n)
  print_green "The current value of ulimit -n is ${ulimit_value}"

  if [ "$ulimit_value" -lt 1000000 ]; then
    print_red "ulimit -n less than 1000000, stopping script execution."
    exit 1
  fi
}

# Function to permanently set ulimit to a specified value
set_ulimit_max_permanently() {
  local ulimit_file="/etc/security/limits.d/ulimit.conf"

  # Check if the file exists
  if [ -f "$ulimit_file" ]; then
    # Extract and print the first soft ulimit value
    local soft_limit=$(grep -m1 "soft nofile" $ulimit_file | awk '{ print $4 }')
    print_green "File $ulimit_file already exists, no modification will be made. The current soft ulimit value is $soft_limit"
  else
    # Write new configuration
    echo "root soft nofile 1048576" | sudo tee -a $ulimit_file
    echo "root hard nofile 1048576" | sudo tee -a $ulimit_file

    print_green "ulimit has been successfully set and stored in $ulimit_file"
  fi
}

# Main function calls
set_ulimit_max_permanently
check_and_disable_swap

Install_JDK_DEBIAN() {
  wget https://cdn.azul.com/zulu/bin/zulu21.30.15-ca-jdk21.0.1-linux_x64.tar.gz
  mkdir -p /usr/java && tar -xzvf zulu21.30.15-ca-jdk21.0.1-linux_x64.tar.gz --strip-components 1 -C /usr/java
  grep -q "export JAVA_HOME=/usr/java" /etc/profile || echo "export JAVA_HOME=/usr/java" >> /etc/profile
  grep -q "\$JAVA_HOME/bin" /etc/profile || echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
  source /etc/profile
}

Install_GRADLE() {
  wget https://services.gradle.org/distributions/gradle-8.8-bin.zip
  mkdir -p /usr/gradle && unzip -q gradle-8.8-bin.zip -d /usr/gradle && mv /usr/gradle/gradle-8.8/* /usr/gradle/
  grep -q "export GRADLE_HOME=/usr/gradle" /etc/profile || echo "export GRADLE_HOME=/usr/gradle" >> /etc/profile
  grep -q "\$GRADLE_HOME/bin" /etc/profile || echo "export PATH=\$GRADLE_HOME/bin:\$PATH" >> /etc/profile
  source /etc/profile
}

Install_Docker_Debian() {
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh ./get-docker.sh
}

Install_Docker_Compose_Debian() {
  # Get the latest version
  COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') || {
    echo "Unable to get the latest version of Docker Compose. Please install manually."
    return 1
  }

  # Download the latest version and add execute permissions
  sudo curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &&
    sudo chmod +x /usr/local/bin/docker-compose || {
    echo "Docker Compose installation failed. Please install manually."
    return 1
  }

  # Display the Docker Compose version to verify installation
  docker-compose --version || {
    echo "Docker Compose installation verification failed. Please check manually."
    return 1
  }

  echo "Docker Compose $COMPOSE_VERSION installed successfully."
}

if [ ! -e "/usr/bin/docker" ]; then
  Install_Docker_Debian
fi

Install_Docker_Compose_Debian

sudo systemctl start docker
sudo systemctl enable docker # Enable on startup

source ~/.bashrc
docker run hello-world
