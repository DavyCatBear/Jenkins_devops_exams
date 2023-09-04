pipeline {
    environment {
        DOCKER_ID = 'davydatascientest'
        DOCKER_IMAGE_CAST = 'datascientestapi-cast'
        DOCKER_IMAGE_MOVIE = 'datascientestapi-movie'
        DOCKER_TAG = "v.${BUILD_ID}.0"
    }
    agent any

    stages {
        stage('Build Docker Images') {
            parallel {
                stage('Build Cast Service Image') {
                    steps {
                        dir('cast-service') {
                            script {
                                try {
                                    sh '''
                                    docker build -t $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG .
                                    '''
                                } catch (Exception e) {
                                    echo "Erreur lors de la construction de l'image Cast Service"
                                    throw e
                                }
                            }
                        }
                    }
                }
                stage('Build Movie Service Image') {
                    steps {
                        dir('movie-service') {
                            script {
                                try {
                                    sh '''
                                    docker build -t $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG .
                                    '''
                                } catch (Exception e) {
                                    echo "Erreur lors de la construction de l'image Movie Service"
                                    throw e
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Push Docker Images') {
            environment {
                DOCKER_PASS = credentials('DOCKER_HUB_PASS')
            }
            steps {
                script {
                    try {
                        sh '''
                        docker login -u $DOCKER_ID -p $DOCKER_PASS
                        docker push $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG
                        docker push $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG
                        '''
                    } catch (Exception e) {
                        echo "Erreur lors de la poussée des images sur Docker Hub"
                        throw e
                    } finally {
                        sh '''
                        docker rmi $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG
                        docker rmi $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG
                        '''
                    }
                }
            }
        }

        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            environment {
                KUBECONFIG = credentials('config')
                Environment = 'dev'
            }
            steps {
                script {
                    deployToKubernetes()
                }
            }
        }

        stage('Deploy to QA') {
            when {
                branch 'qa'
            }
            environment {
                KUBECONFIG = credentials('config')
                Environment = 'qa'
            }
            steps {
                script {
                    deployToKubernetes()
                }
            }
        }

        stage('Deploy to Staging') {
            when {
                branch 'staging'
            }
            environment {
                KUBECONFIG = credentials('config')
                Environment = 'staging'
            }
            steps {
                script {
                    deployToKubernetes()
                }
            }
        }

        stage('Confirm Deploy to Prod') {
            when {
                branch 'master'
            }
            steps {
                script {
                    input "Confirmer le déploiement en production ?"
                }
            }
        }

        stage('Deploy to Prod') {
            when {
                branch 'master'
            }
            environment {
                KUBECONFIG = credentials('config')
                Environment = 'prod'
            }
            steps {
                script {
                    deployToKubernetes()
                }
            }
        }
    }
}

def deployToKubernetes() {
    sh '''
        rm -Rf .kube
        mkdir .kube
        cat $KUBECONFIG > .kube/config
        helm upgrade --install cast-service ./cast-service --set image.tag=$DOCKER_TAG --namespace $Environment
        helm upgrade --install movie-service ./movie-service --set image.tag=$DOCKER_TAG --namespace $Environment
    '''
}

