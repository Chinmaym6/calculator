# Jenkins Pipeline Setup Guide

This Jenkins pipeline automates the deployment of the Calculator React application to an EC2 instance using Docker.

## Prerequisites

### 1. Jenkins Setup
- Jenkins server with Docker plugin installed
- SSH Agent plugin installed
- Pipeline plugin installed

### 2. Required Credentials in Jenkins

#### Docker Hub Credentials
1. Go to Jenkins → Manage Jenkins → Manage Credentials
2. Add credentials with ID: `docker-hub-credentials`
3. Type: Username with password
4. Username: Your Docker Hub username
5. Password: Your Docker Hub password or access token

#### EC2 SSH Key
1. Go to Jenkins → Manage Jenkins → Manage Credentials
2. Add credentials with ID: `ec2-ssh-key`
3. Type: SSH Username with private key
4. Username: `ec2-user` (or `ubuntu` depending on your AMI)
5. Private Key: Your EC2 instance private key (.pem file content)

### 3. EC2 Instance Setup

#### Install Docker on EC2
```bash
# For Amazon Linux 2
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# For Ubuntu
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ubuntu
```

#### Security Group Configuration
- Allow inbound traffic on port 80 (HTTP)
- Allow inbound traffic on port 22 (SSH) from Jenkins server IP

### 4. Pipeline Configuration

#### Update Environment Variables in Jenkinsfile
1. Replace `your-ec2-public-ip` with your actual EC2 public IP address
2. Update `EC2_USER` if using Ubuntu AMI (change to `ubuntu`)
3. Ensure the GitHub repository URL is correct

#### Repository Structure
```
calculator/
├── Dockerfile          # Multi-stage Docker build
├── Jenkinsfile         # Pipeline configuration
├── package.json        # Node.js dependencies
├── src/               # React source code
└── public/            # Static assets
```

## Pipeline Stages

1. **Checkout**: Clone the repository from GitHub
2. **Install Dependencies**: Run `npm ci` to install Node.js packages
3. **Build Application**: Run `npm run build` to create production build
4. **Build Docker Image**: Create Docker image using the Dockerfile
5. **Push to Docker Hub**: Push the image to `chinmay153/todo` repository
6. **Deploy to EC2**: SSH to EC2 and deploy the container
7. **Health Check**: Verify the application is running correctly

## Manual Deployment Steps (if needed)

If you need to deploy manually:

```bash
# On EC2 instance
docker pull chinmay153/todo:latest
docker stop calculator-app || true
docker rm calculator-app || true
docker run -d --name calculator-app -p 80:80 --restart unless-stopped chinmay153/todo:latest
```

## Troubleshooting

### Common Issues

1. **Docker permission denied**
   ```bash
   sudo usermod -a -G docker $USER
   # Then logout and login again
   ```

2. **SSH connection refused**
   - Check EC2 security group allows SSH (port 22)
   - Verify the private key is correct
   - Ensure EC2 instance is running

3. **Docker image not found**
   - Check Docker Hub credentials are correct
   - Verify the image was pushed successfully
   - Check Docker Hub repository exists

4. **Application not accessible**
   - Check EC2 security group allows HTTP (port 80)
   - Verify container is running: `docker ps`
   - Check container logs: `docker logs calculator-app`

### Useful Commands

```bash
# Check container status
docker ps -a

# View container logs
docker logs calculator-app

# Check available images
docker images

# Test application locally
curl http://localhost/
```

## Security Considerations

1. **Use IAM roles** instead of storing AWS credentials in Jenkins
2. **Restrict security groups** to minimum required access
3. **Use private Docker repositories** for sensitive applications
4. **Implement proper secret management** for production environments
5. **Enable HTTPS** with SSL certificates for production

## Monitoring and Maintenance

1. **Set up log rotation** for Docker containers
2. **Monitor disk space** on EC2 instance
3. **Implement backup strategy** for application data
4. **Set up monitoring alerts** for application health
5. **Regular security updates** for EC2 instance and Docker images
