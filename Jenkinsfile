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