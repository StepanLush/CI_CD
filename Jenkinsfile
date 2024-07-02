pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        GIT_CREDENTIALS = credentials('github-ssh-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: "${GIT_CREDENTIALS}", url: 'git@github.com:StepanLush/CI_CD.git'
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

        stage('Update Deployment') {
            steps {
                script {
                    sh "sed -i 's|image: stepanlushch/my-nginx-app:.*|image: ${env.DOCKER_IMAGE_TAG}|' k8s/deployment.yaml"
                }
            }
        }

        stage('Commit and Push Changes') {
            steps {
                script { 
	            sh '''
	                git config --global user.email "lusickijstepan@gmail.com"
	                git config --global user.name "StepanLush"
	                git add k8s/deployment.yaml
	                git commit -m "Update deployment.yaml with new Docker image tag ${DOCKER_IMAGE_TAG}"
	                git push origin master
	            '''
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh 'kubectl --kubeconfig /var/lib/jenkins/.kube/config apply -f k8s/deployment.yaml'
                    sh 'kubectl --kubeconfig /var/lib/jenkins/.kube/config apply -f k8s/service.yaml'
                }
            }
        }
    }
}

