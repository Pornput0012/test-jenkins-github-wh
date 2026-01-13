pipeline {
  agent any

  environment {
    OWNER = "Pornput0012"
    REPO  = "test-jenkins-github-wh"
  }

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

    stage('Run Script') {
      steps {
        sh '''
          echo "Running shell script..."
          sleep 2
        '''
      }
    }

    stage('Comment PR') {
      steps {
        withCredentials([string(credentialsId: 'github-pr-token', variable: 'GITHUB_TOKEN')]) {
          sh '''
            curl -s -X POST \
              -H "Authorization: token $GITHUB_TOKEN" \
              -H "Accept: application/vnd.github+json" \
              https://api.github.com/repos/$OWNER/$REPO/issues/$CHANGE_ID/comments \
              -d '{\"body\":\"✅ Jenkins build passed\"}'
          '''
        }
      }
    }
  }
}

