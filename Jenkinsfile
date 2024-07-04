pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        GIT_CREDENTIALS = credentials('github-ssh-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: "${GIT_CREDENTIALS}", url: 'git@github.com:StepanLush/nginx-chart.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {                    
                    def dockerImage = docker.build("stepanlushch/my-nginx-app:dev-${env.BUILD_ID}")
                    env.DOCKER_IMAGE_TAG = dockerImage.id
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        docker.image(env.DOCKER_IMAGE_TAG).push()
                    }
                }
            }
        }

        stage('Update values.yaml') {
            steps {
                script {
                    def valuesFile = readYaml file: "values.yaml"
                    valuesFile.image.tag = env.DOCKER_IMAGE_TAG
                    writeYaml file: "values.yaml", data: valuesFile
                }
            }
        }

        stage('Commit and Push Changes') {
            steps {
                script { 
                    sh '''
                        git config --global user.email "lusickijstepan@gmail.com"
                        git config --global user.name "StepanLush"
                        git add values.yaml
                        git commit -m "Update values.yaml with new Docker image tag ${DOCKER_IMAGE_TAG}"
                        git push origin main
                    '''
                }
            }
        }

        stage('Helm Upgrade') {
            steps {
                script {
                    sh '''
                        helm upgrade my-release ./ -f values.yaml
                    '''
                }
            }
        }
    }
}

