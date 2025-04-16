pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
                sh 'cd nodejs-app'
                sh 'docker build -t cillu/nodejs-app:latest .'
                sh 'docker push cillu/nodejs-app:latest'
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