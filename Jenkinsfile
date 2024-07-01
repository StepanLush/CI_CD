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
                    docker.build("stepanlushch/my-nginx-app:latest")
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        docker.image('stepanlushch/my-nginx-app:latest').push()
                    }
                }
            }
        }
        stage('Deploy to Minikube') {
            steps {
                sh 'kubectl --kubeconfig /var/lib/jenkins/.kube/config apply -f k8s/deployment.yaml'
                sh 'kubectl --kubeconfig /var/lib/jenkins/.kube/config apply -f k8s/service.yaml'
            }
        }
    }
}
