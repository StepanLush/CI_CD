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
                    withCredentials([sshUserPrivateKey(credentialsId: 'github-ssh-credentials', keyFileVariable: 'SSH_KEY')]) {
                        sh '''
                            # Add GitHub to known hosts
                            ssh-keyscan github.com >> ~/.ssh/known_hosts

                            git config user.email "lusickijstepan@gmail.com"
                            git config user.name "StepanLush"
                            git add k8s/deployment.yaml
                            git commit -m "Update deployment.yaml with new Docker image tag ${DOCKER_IMAGE_TAG}"
                            git remote set-url origin git@github.com:StepanLush/CI_CD.git
                            GIT_SSH_COMMAND="ssh -i ${SSH_KEY}" git push -u origin master
                        '''
                    }
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

