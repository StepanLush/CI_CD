pipeline {
    agent any

    environment {
        REGISTRY = "stepanlushch"
        IMAGE = "my-nginx-app"
        TAG = "latest"
        KUBE_CONTEXT = "minikube"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.REGISTRY}/${env.IMAGE}:${env.TAG}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('', 'docker-credentials-id') {
                        docker.image("${env.REGISTRY}/${env.IMAGE}:${env.TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    kubectl("apply -f k8s/deployment.yaml")
                }
            }
        }
    }
}

def kubectl(command) {
    sh "kubectl --context ${env.KUBE_CONTEXT} ${command}"
}
