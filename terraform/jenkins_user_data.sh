#!/bin/bash
# Update system
sudo apt update -y
sudo apt upgrade -y

# Install Java 17
sudo apt install -y openjdk-17-jdk

# Set JAVA_HOME
echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" | sudo tee -a /etc/environment
source /etc/environment

# Install required packages
sudo apt install -y gnupg2 curl git maven

# Add Jenkins repo
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list

# Install Jenkins
sudo apt update -y
sudo apt install -y jenkins

# Fix permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins /var/cache/jenkins /var/log/jenkins

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Print initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
