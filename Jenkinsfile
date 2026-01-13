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
            error "Not a PR build"
          }
        }
      }
    }

    stage('Run Script') {
      steps {
        sh '''
          echo "Running shell script..."
          sleep 2
          echo "Done"
        '''
      }
    }

    stage('Check automerge label') {
      steps {
        withCredentials([string(credentialsId: 'github-pr-token', variable: 'GITHUB_TOKEN')]) {
          sh '''
            LABELS=$(curl -s \
              -H "Authorization: token $GITHUB_TOKEN" \
              -H "Accept: application/vnd.github+json" \
              https://api.github.com/repos/$OWNER/$REPO/issues/$CHANGE_ID/labels)

            echo "$LABELS" | grep '"name": *"automerge"' || {
              echo "❌ automerge label not found"
              exit 1
            }

            echo "✅ automerge label found"
          '''
        }
      }

	stage('Auto delete branch') {
  		when {
    			allOf {
      				expression { env.CHANGE_BRANCH != null }
      				expression { currentBuild.currentResult == 'SUCCESS' }
    			}
  		}
  		steps {
    			withCredentials([string(credentialsId: 'github-pr-token', variable: 'GITHUB_TOKEN')]) {
      			sh '''
        echo "Deleting branch: ${CHANGE_BRANCH}"

        if [ "${CHANGE_BRANCH}" = "main" ]; then
          echo "Refusing to delete main"
          exit 0
        fi

        curl -s -X DELETE \
          -H "Authorization: token ${GITHUB_TOKEN}" \
          -H "Accept: application/vnd.github+json" \
          https://api.github.com/repos/Pornput0012/test-jenkins-github-wh/git/refs/heads/${CHANGE_BRANCH}
      			'''
    		}
  }
}

    }
  }

  post {
    success {
      withCredentials([string(credentialsId: 'github-pr-token', variable: 'GITHUB_TOKEN')]) {
        sh '''
          echo "Merging PR #$CHANGE_ID"

          curl -s -X PUT \
            -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github+json" \
            https://api.github.com/repos/$OWNER/$REPO/pulls/$CHANGE_ID/merge \
            -d '{"merge_method":"squash"}'
        '''

        sh '''
          curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            https://api.github.com/repos/$OWNER/$REPO/issues/$CHANGE_ID/comments \
            -d '{"body":"🚀 PR auto-merged by Jenkins"}'
        '''
      }
    }

    failure {
      withCredentials([string(credentialsId: 'github-pr-token', variable: 'GITHUB_TOKEN')]) {
        sh '''
          curl -s -X POST \
            -H "Authorization: token $GITHUB_TOKEN" \
            https://api.github.com/repos/$OWNER/$REPO/issues/$CHANGE_ID/comments \
            -d '{"body":"❌ Build failed or automerge label missing"}'
        '''
      }
    }
  }
}

