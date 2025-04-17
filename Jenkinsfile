pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                sh script:'''
                    #!/bin/bash
                    cd nodejs-app
                    docker build -t cillu/nodejs-app:latest .
                    docker push cillu/nodejs-app:latest
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
            }
        }
    }

    post {
        always {
            echo 'This will always run after the stages.'
        }
    }
}