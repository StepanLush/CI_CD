pipeline {
    agent any

    environment {
        GIT_CREDENTIALS = credentials('github-ssh-credentials')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', credentialsId: "${GIT_CREDENTIALS}", url: 'git@github.com:StepanLush/nginx-chart.git'
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
		    sh """
		        sed -i 's|tag: .*|tag: ${env.DOCKER_IMAGE_TAG}|' values.yaml
		    """
		}
	    }
	}

        stage('Commit and Push Changes') {
            steps {
                script {
                    sh '''
                        git config --global user.email "lusickijstepan@gmail.com"
                        git config --global user.name "StepanLush"
                        git add ./values.yaml
                        git commit -m "Update values.yaml with new tag"
                        git push origin master
                    '''
                }
            }
        }

        stage('Helm Upgrade') {
            steps {
                script {
                    sh '''
                        helm upgrade nginx ./ -f values.yaml
                    '''
                }
            }
        }
    }
}

