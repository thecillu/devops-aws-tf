pipeline {
    agent any

    //triggers {
    //    pollSCM 'H/1 * * * *'
    //}
    
    stages {

        stage('Checkout') {
            steps {
                checkout scm: [$class: 'GitSCM', 
                userRemoteConfigs: [[url: 'https://github.com/thecillu/devops-aws-tf']], 
                branches: [[name: 'refs/tags/v0.2.0']]], changelog: false, poll: false
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