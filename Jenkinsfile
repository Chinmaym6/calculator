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
        
        stage('Verify Files') {
            steps {
                echo 'Verifying Dockerfile exists...'
                sh 'ls -la'
                sh 'pwd'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image using shell commands...'
                sh """
                    # Clean up any existing failed builds
                    docker system prune -f || true
                    
                    # Build the Docker image (removed --progress flag for compatibility)
                    docker build --no-cache -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                    
                    # Verify images were created
                    docker images | grep ${DOCKER_IMAGE}
                """
            }
        }
        
        stage('Login to Docker Hub') {
            steps {
                echo 'Logging into Docker Hub...'
                sh """
                    echo \$DOCKER_HUB_CREDENTIALS_PSW | docker login -u \$DOCKER_HUB_CREDENTIALS_USR --password-stdin
                """
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                sh """
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker push ${DOCKER_IMAGE}:latest
                """
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
                sshagent(['ec2-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                            echo "=== Docker Container Status ==="
                            docker ps -a | grep calculator-app
                            
                            echo "=== Container Logs ==="
                            docker logs calculator-app --tail 10
                            
                            echo "=== Port Check ==="
                            sudo netstat -tulpn | grep :80
                            
                            echo "=== Local Curl Test ==="
                            curl -v http://localhost/ || true
                        '
                    """
                }
                
                echo 'Testing external access...'
                sh """
                    # Wait a bit for the application to start
                    sleep 15
                    
                    # Check if the application is responding externally
                    curl -v http://${EC2_HOST}/ || echo "External access failed"
                """
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace and Docker images...'
            sh """
                # Logout from Docker Hub
                docker logout || true
                # Clean up local images to save space
                docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG} || true
                docker rmi ${DOCKER_IMAGE}:latest || true
            """
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}