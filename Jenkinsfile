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
        }
    }

    post {
        success {
            withCredentials([string(credentialsId: 'github-pr-token', variable: 'GITHUB_TOKEN')]) {
                script {
                    // 1. Merge PR
                    echo "🚀 Merging PR #$CHANGE_ID"
                    sh '''
                        curl -s -X PUT \
                        -H "Authorization: token $GITHUB_TOKEN" \
                        -H "Accept: application/vnd.github+json" \
                        https://api.github.com/repos/$OWNER/$REPO/pulls/$CHANGE_ID/merge \
                        -d '{"merge_method":"squash"}'
                    '''

                    // 2. ดึง labels เพื่อเช็ก autodelete
                    def labelsJson = sh(
                        script: "curl -s -H 'Authorization: token $GITHUB_TOKEN' https://api.github.com/repos/$OWNER/$REPO/issues/$CHANGE_ID/labels",
                        returnStdout: true
                    ).trim()
                    
                    // ใช้การเช็ก string พื้นฐานเผื่อไม่มี plugin readJSON
                    if (labelsJson.contains('"name":"autodelete"') || labelsJson.contains('"name": "autodelete"')) {
                        if (env.CHANGE_BRANCH != 'main') {
                            echo "🧹 Deleting branch: ${env.CHANGE_BRANCH}"
                            sh """
                                curl -s -X DELETE \
                                -H "Authorization: token $GITHUB_TOKEN" \
                                https://api.github.com/repos/$OWNER/$REPO/git/refs/heads/${env.CHANGE_BRANCH}
                            """
                        }
                    }

                    // 3. Comment บอกสถานะ
                    sh '''
                        curl -s -X POST \
                        -H "Authorization: token $GITHUB_TOKEN" \
                        https://api.github.com/repos/$OWNER/$REPO/issues/$CHANGE_ID/comments \
                        -d '{"body":"🚀 PR auto-merged and cleaned up by Jenkins"}'
                    '''
                }
            }
        }
        failure {
            withCredentials([string(credentialsId: 'github-pr-token', variable: 'GITHUB_TOKEN')]) {
                sh '''
                    curl -s -X POST \
                    -H "Authorization: token $GITHUB_TOKEN" \
                    https://api.github.com/repos/$OWNER/$REPO/issues/$CHANGE_ID/comments \
                    -d '{"body":"❌ Build failed or requirements not met"}'
                '''
            }
        }
    }
}
