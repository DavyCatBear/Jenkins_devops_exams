pipeline {
    environment {
        DOCKER_ID = "davydatascientest"
    }
    agent any

    stages {
        stage('Build & Test') {
            parallel {
                stage('Build & Test Cast Service') {
                    steps {
                        dir('cast-service') {
                            sh '''
                            docker build -t $DOCKER_ID/datascientestapi-cast:v1 .
                            docker run -d -p 8080:80 --name cast-service $DOCKER_ID/datascientestapi-cast:v1
                            sleep 10
                            curl localhost:8080
                            '''
                        }
                    }
                }
                stage('Build & Test Movie Service') {
                    steps {
                        dir('movie-service') {
                            sh '''
                            docker build -t $DOCKER_ID/datascientestapi-movie:v1 .
                            docker run -d -p 8081:80 --name movie-service $DOCKER_ID/datascientestapi-movie:v1
                            sleep 10
                            curl localhost:8081
                            '''
                        }
                    }
                }
            }
        }

        stage('Docker Push') {
            environment {
                DOCKER_PASS = credentials("DOCKER_HUB_PASS")
            }
            steps {
                sh '''
                docker login -u $DOCKER_ID -p $DOCKER_PASS
                docker push $DOCKER_ID/datascientestapi-cast:v1
                docker push $DOCKER_ID/datascientestapi-movie:v1
                '''
            }
        }

        stage('Deploy to Environments') {
            steps {
                deployToK8s('dev')
                deployToK8s('qa')
                deployToK8s('staging')
            }
        }

        stage('Deploy to Prod') {
            when {
                branch 'master'
            }
            steps {
                timeout(time: 15, unit: "MINUTES") {
                    input message: 'Do you want to deploy in production?', ok: 'Yes'
                }
                deployToK8s('prod')
            }
        }
    }
}

def deployToK8s(env) {
    environment {
        KUBECONFIG = credentials("config")
    }
    sh '''
    rm -Rf .kube
    mkdir .kube
    cat $KUBECONFIG > .kube/config
    cp fastapi/values.yaml values.yml
    sed -i "s+tag.*+tag: v1+g" values.yml
    helm upgrade --install app fastapi --values=values.yml --namespace $env
    '''
}

