pipeline {
  agent any

  stages {
    stage('Check PR') {
      steps {
        script {
          if (!env.CHANGE_ID) {
            error "This pipeline runs only for Pull Requests"
          }
        }
      }
    }

    stage('Info') {
      steps {
        echo "PR Number: ${env.CHANGE_ID}"
        echo "Source: ${env.CHANGE_BRANCH}"
        echo "Target: ${env.CHANGE_TARGET}"
      }
    }

    stage('Run Script') {
      steps {
        sh '''
          echo "Running shell script for PR..."
          sleep 2
          echo "Script finished"
        '''
      }
    }
  }
}

