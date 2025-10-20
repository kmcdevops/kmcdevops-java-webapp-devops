pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/kmcdevops/kmcdevops-java-webapp-devops.git', branch: 'main'
      }
    }

    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Copy WAR to tmp') {
      steps {
        sh 'cp target/*.war /tmp/app.war'
      }
    }

    stage('Install Tomcat on App Server') {
      steps {
        sshagent (credentials: ['app-key']) {
          sh '''
            ansible-playbook -i ansible/hosts.ini ansible/tomcat.yml
          '''
        }
      }
    }

    stage('Deploy WAR to App Server') {
      steps {
        sshagent (credentials: ['app-key']) {
          sh '''
            ansible-playbook -i ansible/hosts.ini ansible/deploy.yml
          '''
        }
      }
    }
  }
}