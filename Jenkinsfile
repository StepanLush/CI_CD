pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        GITHUB_CREDENTIALS = credentials('github-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/StepanLush/CI_CD',
                    credentialsId: 'github-credentials'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {                    
                    def dockerImage = docker.build("stepanlushch/my-nginx-app:dev-${env.BUILD_NUMBER}-${env.BUILD_ID}")
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

        stage('Deploy to Minikube') {
            steps {
                script {
                    sh "sed -i 's|image: stepanlushch/my-nginx-app:.*|image: ${env.DOCKER_IMAGE_TAG}|' k8s/deployment.yaml"
                    sh 'kubectl --kubeconfig /var/lib/jenkins/.kube/config apply -f k8s/deployment.yaml'
                    sh 'kubectl --kubeconfig /var/lib/jenkins/.kube/config apply -f k8s/service.yaml'
                }
            }
        }
    }
}

