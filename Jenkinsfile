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

        stage('Update values.yaml') {
            steps {
                script {
                    def newTag = "dev-${env.BUILD_ID}"
                    def valuesFile = readYaml file: "values.yaml"
                    valuesFile.image.tag = newTag
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
                        git commit -m "Update values.yaml with new tag dev-${env.BUILD_ID}"
                        git push origin master
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

