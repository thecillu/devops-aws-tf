pipeline {
    agent any

    triggers {
        pollSCM 'H/1 * * * *'
    }
    
    stages {
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