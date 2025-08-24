pipeline {
    agent any
    
    environment {
        // Docker Hub credentials - configure these in Jenkins credentials
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'chinmay153/todo'
        DOCKER_TAG = "${BUILD_NUMBER}"
        // EC2 credentials - configure these in Jenkins credentials
        EC2_CREDENTIALS = credentials('ec2-ssh-key')
        EC2_HOST = '54.161.195.40' // Replace with your EC2 public IP
        EC2_USER = 'ubuntu'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                git branch: 'main', 
                    url: 'https://github.com/Chinmaym6/calculator.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image (this will install dependencies and build the app)...'
                script {
                    // Build the Docker image - this handles npm install and npm build internally
                    def image = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                    // Also tag as latest
                    image.tag("latest")
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                        docker.image("${DOCKER_IMAGE}:latest").push()
                    }
                }
            }
        }
        
        stage('Deploy to EC2') {
            steps {
                echo 'Deploying to EC2 instance...'
                sshagent(['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                            # Stop and remove existing container if running
                            docker stop calculator-app || true
                            docker rm calculator-app || true
                            
                            # Remove old images to save space
                            docker rmi ${DOCKER_IMAGE}:latest || true
                            
                            # Pull latest image
                            docker pull ${DOCKER_IMAGE}:latest
                            
                            # Run new container
                            docker run -d --name calculator-app -p 80:80 --restart unless-stopped ${DOCKER_IMAGE}:latest
                            
                            # Verify deployment
                            sleep 10
                            docker ps | grep calculator-app
                        '
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                script {
                    sh """
                        # Wait a bit for the application to start
                        sleep 15
                        
                        # Check if the application is responding
                        curl -f http://${EC2_HOST}/ || exit 1
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
            // You can add notification steps here (email, Slack, etc.)
        }
        failure {
            echo 'Pipeline failed!'
            // You can add failure notification steps here
        }
    }
}