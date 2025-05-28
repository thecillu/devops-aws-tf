pipeline {
    agent any

    //triggers {
    //    pollSCM 'H/1 * * * *'
    //}
    
    parameters {
        gitParameter type: 'PT_TAG',
                    name: 'Tag',
                    defaultValue: 'v0.1.0',
                    description: 'Choose a tag to checkout',
                    selectedValue: 'DEFAULT',
                    sortMode: 'DESCENDING_SMART'
    }

    stages {
        stage('Checkout') {
            steps {
                dir("app-dir"){
                    sh 'ls -al'
                    checkout scm: [$class: 'GitSCM', 
                    userRemoteConfigs: [[url: 'https://github.com/thecillu/devops-aws-tf']], 
                    branches: [[name: "refs/tags/${params.Tag}"]]], changelog: false, poll: false
                    sh 'pwd'
                    sh 'ls -al'
                }

                dir("terraform-dir"){
                    sh 'ls -al'
                    checkout scm: [$class: 'GitSCM', 
                    userRemoteConfigs: [[url: 'https://github.com/thecillu/devops-aws-tf']], 
                    branches: [[name: "refs/tags/v0.1.0"]]], changelog: false, poll: false
                    sh 'pwd'
                    sh 'ls -al'
                }
                
                sh 'pwd'
                sh 'ls -al'
            }
        }

        stage('Create Artifact') {
            steps {
                script {
                    // Create a tar.gz archive of the built application
                    sh """
                        cd nodejs-app
                        tar -czf nodejs-app.tar.gz \
                            --exclude=node_modules \
                            --exclude=.git \
                            --exclude=test \
                            --exclude=*.log \
                            .
                    """
                }
                
                // Archive the artifact
                archiveArtifacts artifacts: "nodejs-app.tar.gz", fingerprint: true
            }
        }

        stage('Build') {
            steps {
                echo 'Building...'
                sh script:'''
                    #!/bin/bash
                    cd nodejs-app
                    docker build -t cillu/nodejs-app:latest .
                '''
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    // Manual approval step
                    def userInput = input(
                        id: 'Proceed1', 
                        message: 'Deploy to Test Environment?',
                        description: 'Review the build artifacts and decide whether to proceed with deployment to the test environment.',
                        parameters: [
                            choice(
                                choices: ['Deploy', 'Abort'],
                                description: 'Choose action',
                                name: 'ACTION'
                            ),
                            text(
                                defaultValue: '',
                                description: 'Optional: Add deployment notes',
                                name: 'DEPLOYMENT_NOTES'
                            )
                        ],
                        submitter: 'admin,deploy-team',  // Specify who can approve
                        submitterParameter: 'APPROVER'
                    )
                    
                    // Store approval details
                    env.DEPLOYMENT_ACTION = userInput.ACTION
                    env.DEPLOYMENT_NOTES = userInput.DEPLOYMENT_NOTES
                    env.APPROVED_BY = userInput.APPROVER
                    
                    if (userInput.ACTION == 'Abort') {
                        error('Deployment aborted by user')
                    }
                    
                    echo "Deployment approved by: ${env.APPROVED_BY}"
                    if (env.DEPLOYMENT_NOTES) {
                        echo "Deployment notes: ${env.DEPLOYMENT_NOTES}"
                    }
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Testing...'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh script:'''
                    #!/bin/bash
                    docker push cillu/nodejs-app:latest
                '''
            }
        }
    }

    post {
        always {
            echo 'This will always run after the stages.'
        }
    }
}