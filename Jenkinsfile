pipeline {
  agent any

  stages {
    stage('Info') {
      steps {
        echo "Branch: ${env.BRANCH_NAME}"
        echo "Is PR: ${env.CHANGE_ID != null}"
        echo "PR Number: ${env.CHANGE_ID}"
        echo "Source Branch: ${env.CHANGE_BRANCH}"
        echo "Target Branch: ${env.CHANGE_TARGET}"
      }
    }

    stage('Run Script') {
      steps {
        sh '''
          echo "Running shell script..."
          echo "Hello from Jenkins PR pipeline"
        '''
      }
    }
  }
}
