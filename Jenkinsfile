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
                            sh 'docker build -t $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG .'
                        }
                    }
                }
                stage('Build Movie Service Image') {
                    steps {
                        dir('movie-service') {
                            sh 'docker build -t $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG .'
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
                sh '''
                    docker login -u $DOCKER_ID -p $DOCKER_PASS
                    docker push $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG
                    docker push $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG
                '''
            }
            post {
                always {
                    sh '''
                        docker rmi $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG
                        docker rmi $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG
                    '''
                }
            }
        }

        stage('Deploy to Dev') {
            //when {
              //  branch 'develop'
            //}
            environment {
                KUBECONFIG = credentials('config')
                DEPLOY_ENV = 'dev'
            }
            steps {
                script {
                    deployToKubernetes()
                }
            }
        }

        stage('Deploy to QA') {
            //when {
              //  branch 'qa'
            //}
            environment {
                KUBECONFIG = credentials('config')
                DEPLOY_ENV = 'qa'
            }
            steps {
                script {
                    deployToKubernetes()
                }
            }
        }

        stage('Deploy to Staging') {
            //when {
              //  branch 'staging'
            //}
            environment {
                KUBECONFIG = credentials('config')
                DEPLOY_ENV = 'staging'
            }
            steps {
                script {
                    deployToKubernetes()
                }
            }
        }

        stage('Confirm Deploy to Prod') {
            //when {
              //  branch 'master'
            //}
            steps {
                input "Confirmer le déploiement en production ?"
            }
        }

        stage('Deploy to Prod') {
            //when {
              //  branch 'master'
            //}
            environment {
                KUBECONFIG = credentials('config')
                DEPLOY_ENV = 'prod'
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
        helm upgrade --install cast-service ./cast-service --set image.tag=$DOCKER_TAG --namespace $DEPLOY_ENV
        helm upgrade --install movie-service ./movie-service --set movie_service.image.tag=$DOCKER_TAG,movie_db.image.tag=12.1-alpine --namespace $DEPLOY_ENV
    '''
}

