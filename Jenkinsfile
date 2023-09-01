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
                                sh '''
                                docker build -t $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG .
                                '''
                            }
                        }
                    }
                }
                stage('Build Movie Service Image') {
                    steps {
                        dir('movie-service') {
                            script {
                                sh '''
                                docker build -t $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG .
                                '''
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
                    sh '''
                    docker login -u $DOCKER_ID -p $DOCKER_PASS
                    docker push $DOCKER_ID/$DOCKER_IMAGE_CAST:$DOCKER_TAG
                    docker push $DOCKER_ID/$DOCKER_IMAGE_MOVIE:$DOCKER_TAG
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            environment {
                KUBECONFIG = credentials('config')
            }
            steps {
                script {
                    sh '''
                    rm -Rf .kube
                    mkdir .kube
                    cat $KUBECONFIG > .kube/config
		    '''	
                }
            }
        }
    }
}
