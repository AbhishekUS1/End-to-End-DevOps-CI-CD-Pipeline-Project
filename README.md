End-to-End CI/CD Pipeline for Containerized Web Application
===========================================================
🚀 Project Overview
-------------------

A complete end-to-end CI/CD pipeline for deploying a web application on Kubernetes using AWS, Terraform, Jenkins, Docker, DockerHub, and MicroK8s. This project demonstrates modern DevOps practices including Infrastructure as Code (IaC), containerization, continuous integration, and automated deployment.

### Architecture Diagram

text

GitHub (Code) → Jenkins (CI/CD) → Docker (Build) → DockerHub (Registry) → Kubernetes (Deploy) → AWS EC2 (Runtime)
     ↑                                     ↑
Terraform (Infrastructure)           MicroK8s (Orchestration)

✨ Key Features
--------------

-   Infrastructure as Code: Automated AWS EC2 provisioning with Terraform

-   Complete CI/CD Pipeline: Jenkins automates build, test, and deployment

-   Containerization: Docker-based application packaging

-   Kubernetes Deployment: Scalable container orchestration with MicroK8s

-   Automated Workflow: Zero-touch deployment on code changes

-   Version Control: All infrastructure and application code is versioned

🏗️ Architecture Workflow
-------------------------

1.  Infrastructure Provisioning: Terraform creates EC2 instance

2.  Tool Installation: Jenkins, Docker, MicroK8s installed on EC2

3.  CI/CD Pipeline: Jenkins pulls code, builds, and deploys

4.  Container Registry: Docker images pushed to DockerHub

5.  Kubernetes Deployment: Application deployed on MicroK8s cluster

6.  Service Exposure: Application accessible via NodePort

📁 Project Structure
--------------------
"""
scroll-web/
├── infrastructure/
│   ├── main.tf           # Terraform configuration
│   ├── variables.tf      # Terraform variables
│   └── outputs.tf        # Terraform outputs
├── application/
│   ├── Dockerfile        # Docker container definition
│   ├── index.html        # Web application
│   └── nginx.conf        # Nginx configuration (optional)
├── kubernetes/
│   └── deploy.yaml       # Kubernetes deployment manifest
├── Jenkinsfile           # Jenkins pipeline definition
└── README.md            # Project documentation
"""

🚀 Quick Start Guide
--------------------

### Prerequisites

-   AWS Account with IAM credentials

-   Terraform (≥ 1.0)

-   AWS CLI configured

-   DockerHub account

-   GitHub repository access

### Step 1: Infrastructure Provisioning

#### Terraform Configuration (`main.tf`)

hcl

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0dee22c13ea7a9a67" # Amazon Linux 2 in ap-south-1
  instance_type = "t2.medium"
  key_name      = "project-1"

  vpc_security_group_ids = ["sg-xxxxxxxx"] # Your security group

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }

  tags = {
    Name = "Jenkins-CI-CD-Server"
    Environment = "Production"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Installation scripts for Jenkins, Docker, MicroK8s
              EOF
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "jenkins_url" {
  value = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

#### Apply Terraform Configuration

bash

cd infrastructure/
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

### Step 2: Server Setup Script

Create `setup.sh` for automated installation:

bash

#!/bin/bash

# Update system
sudo yum update -y

# Install Java (Jenkins dependency)
sudo yum install -y java-11-openjdk-devel

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker ec2-user

# Install MicroK8s
sudo snap install microk8s --classic
sudo usermod -a -G microk8s ec2-user
sudo microk8s status --wait-ready

# Enable MicroK8s addons
sudo microk8s enable dns
sudo microk8s enable registry
sudo microk8s enable dashboard

# Install kubectl
sudo snap install kubectl --classic

# Configure alias for MicroK8s kubectl
echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
source ~/.bashrc

# Get Jenkins initial admin password
echo "Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

### Step 3: Application Containerization

#### Dockerfile

dockerfile

FROM nginx:alpine
LABEL maintainer="Your Name <your.email@example.com>"
LABEL version="1.0"
LABEL description="Nginx web server for scroll-web application"

# Copy custom configuration (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Copy application files
COPY index.html /usr/share/nginx/html/index.html
COPY assets/ /usr/share/nginx/html/assets/  # If you have assets

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3\
  CMD curl -f http://localhost/ || exit 1

# Run nginx
CMD ["nginx", "-g", "daemon off;"]

### Step 4: Jenkins Pipeline Configuration

#### Jenkinsfile (Declarative Pipeline)

groovy

pipeline {
    agent any

    environment {
        // Docker configuration
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'yourusername/scroll-web'
        DOCKER_TAG = "${env.BUILD_NUMBER}"

        // Kubernetes configuration
        K8S_NAMESPACE = 'scroll-web'
        K8S_DEPLOYMENT = 'scroll-web-deployment'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout scm
                sh 'echo "Repository cloned successfully"'
            }
        }

        stage('Code Quality Check') {
            steps {
                sh '''
                    echo "Running code quality checks..."
                    # Add your linting/validation commands here
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh """
                        docker build\
                            -t ${DOCKER_IMAGE}:${DOCKER_TAG}\
                            -t ${DOCKER_IMAGE}:latest\
                            .
                    """
                }
            }
        }

        stage('Run Tests') {
            steps {
                sh '''
                    echo "Running container tests..."
                    # Add container tests if applicable
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'docker-hub-credentials',
                            usernameVariable: 'DOCKER_USERNAME',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]) {
                        sh """
                            echo "Logging into Docker Hub..."
                            echo \$DOCKER_PASSWORD | docker login\
                                -u \$DOCKER_USERNAME\
                                --password-stdin

                            echo "Pushing images to Docker Hub..."
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG} docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo "Deploying to Kubernetes..."
                    sh """
                        # Update deployment with new image
                        kubectl set image deployment/${K8S_DEPLOYMENT}\
                            devops-app-c5=${DOCKER_IMAGE}:${DOCKER_TAG}\
                            -n ${K8S_NAMESPACE}\
                            --record

                        # Check rollout status
                        kubectl rollout status deployment/${K8S_DEPLOYMENT}\
                            -n ${K8S_NAMESPACE}\
                            --timeout=300s
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    echo "Performing health check..."
                    # Add health check commands
                    sleep 10
                    curl -f http://localhost:30326/ || exit 1
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
            slackSend(color: 'good', message: "Build ${env.BUILD_NUMBER} succeeded!")
        }
        failure {
            echo 'Pipeline failed!'
            slackSend(color: 'danger', message: "Build ${env.BUILD_NUMBER} failed!")
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}

### Step 5: Kubernetes Deployment

#### deploy.yaml

yaml

---
# Namespace Configuration
apiVersion: v1
kind: Namespace
metadata:
  name: scroll-web
  labels:
    name: scroll-web
    environment: production

---
# Deployment Configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scroll-web-deployment
  namespace: scroll-web
  labels:
    app: scroll-web
    tier: frontend
spec:
  replicas: 2
  revisionHistoryLimit: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: scroll-web
      tier: frontend
  template:
    metadata:
      labels:
        app: scroll-web
        tier: frontend
        version: "v1.0"
    spec:
      containers:
      - name: web-app
        image: yourusername/scroll-web:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
          name: http
          protocol: TCP
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5

---
# Service Configuration
apiVersion: v1
kind: Service
metadata:
  name: scroll-web-service
  namespace: scroll-web
  labels:
    app: scroll-web
    service: web
spec:
  type: NodePort
  selector:
    app: scroll-web
    tier: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30326

---
# Ingress Configuration (Optional - for production)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: scroll-web-ingress
  namespace: scroll-web
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: scroll-web-service
            port:
              number: 80

⚙️ Configuration Guide
----------------------

### AWS Configuration

1.  Create IAM user with EC2 full access

2.  Generate access keys

3.  Configure AWS CLI:

    bash

    aws configure

### Jenkins Configuration

1.  Access Jenkins at `http://<EC2_PUBLIC_IP>:8080`

2.  Install suggested plugins

3.  Create admin user

4.  Install required plugins:

    -   Docker Pipeline

    -   Kubernetes CLI

    -   Git

    -   Credentials Binding

### DockerHub Credentials in Jenkins

1.  Go to Jenkins → Credentials → System → Global credentials

2.  Add credentials:

    -   Kind: Username with password

    -   ID: `docker-hub-credentials`

    -   Username: Your DockerHub username

    -   Password: Your DockerHub password/token

### MicroK8s Configuration

bash

# Configure kubectl to use MicroK8s
microk8s config > ~/.kube/config

# Verify cluster status
microk8s kubectl get nodes
microk8s kubectl get pods --all-namespaces

# Deploy application
microk8s kubectl apply -f deploy.yaml

📊 Monitoring & Logging
-----------------------

### View Application Logs

bash

# View pod logs
kubectl logs -f deployment/scroll-web-deployment -n scroll-web

# View pod status
kubectl get pods -n scroll-web -w

# View service details
kubectl describe service scroll-web-service -n scroll-web

### Access Application

-   Local Access: `http://localhost:30326`

-   Remote Access: `http://<EC2_PUBLIC_IP>:30326`

-   Kubernetes Dashboard: `microk8s dashboard-proxy`

🔧 Troubleshooting
------------------

### Common Issues and Solutions

#### 1\. Terraform AWS Authentication Error

bash

# Solution: Configure AWS credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"

#### 2\. Docker Permission Denied

bash

# Solution: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

#### 3\. Jenkins Docker Pipeline Error

bash

# Solution: Restart Jenkins with Docker permissions
sudo systemctl restart jenkins

#### 4\. MicroK8s Not Starting

bash

# Solution: Check MicroK8s status
microk8s status --wait-ready
microk8s inspect

#### 5\. Application Not Accessible

bash

# Check service is running
kubectl get svc -n scroll-web

# Check firewall rules
sudo ufw allow 30326
sudo ufw allow 8080

📈 Scaling the Application
--------------------------

### Horizontal Pod Autoscaling

yaml

apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: scroll-web-hpa
  namespace: scroll-web
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scroll-web-deployment
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

### Scale Manually

bash

# Scale deployment
kubectl scale deployment scroll-web-deployment --replicas=5 -n scroll-web

# Check scaling status
kubectl get hpa -n scroll-web

🔄 Rollback Strategy
--------------------

### Manual Rollback

bash

# Check rollout history
kubectl rollout history deployment/scroll-web-deployment -n scroll-web

# Rollback to previous version
kubectl rollout undo deployment/scroll-web-deployment -n scroll-web

# Rollback to specific revision
kubectl rollout undo deployment/scroll-web-deployment --to-revision=2 -n scroll-web

🧪 Testing the Pipeline
-----------------------

### Run Complete Pipeline Test

bash

# 1. Make code change
echo "<h1>Version 2.0</h1>" > index.html

# 2. Commit and push
git add .
git commit -m "Update application to version 2.0"
git push origin main

# 3. Watch Jenkins pipeline
# 4. Verify deployment
curl http://<EC2_PUBLIC_IP>:30326

📝 Interview-Friendly Summary
-----------------------------

### Project Title

End-to-End CI/CD Pipeline for Containerized Web Application using AWS, Terraform, Jenkins, Docker, DockerHub & Kubernetes

### Key Achievements

-   ✅ Automated infrastructure provisioning using Terraform (Infrastructure as Code)

-   ✅ Complete CI/CD pipeline implementation with Jenkins

-   ✅ Docker containerization with multi-tag support

-   ✅ Automated deployment to Kubernetes (MicroK8s)

-   ✅ Scalable architecture with 2+ replicas

-   ✅ Zero-downtime deployments with rolling updates

-   ✅ Comprehensive monitoring and logging setup

-   ✅ Version-controlled everything (infrastructure + application)

### Technical Stack

-   Infrastructure: AWS EC2, Terraform

-   CI/CD: Jenkins, Docker, DockerHub

-   Orchestration: Kubernetes (MicroK8s)

-   Web Server: Nginx

-   Version Control: GitHub

### Deployment Flow

text

Developer Push → GitHub → Jenkins Trigger → Docker Build →
DockerHub Push → Kubernetes Update → Application Live

### Access Points

-   Jenkins Dashboard: `http://<EC2_IP>:8080`

-   Application: `http://<EC2_IP>:30326`

-   Kubernetes Dashboard: Via `microk8s dashboard-proxy`

🤝 Contributing
---------------

Contributions are welcome! Please follow these steps:

1.  Fork the repository

2.  Create a feature branch (`git checkout -b feature/improvement`)

3.  Commit changes (`git commit -am 'Add new feature'`)

4.  Push to branch (`git push origin feature/improvement`)

5.  Create Pull Request

### Development Guidelines

-   Maintain backward compatibility

-   Update documentation for new features

-   Add tests for new functionality

-   Follow existing code style

📄 License
----------

This project is licensed under the MIT License - see the [LICENSE](https://license/) file for details.

🙏 Acknowledgments
------------------

-   Inspired by real-world DevOps practices

-   Built with open-source technologies

-   Special thanks to the DevOps community for best practices

📞 Support
----------

For support or questions:

1.  Check the troubleshooting section

2.  Open a GitHub issue

3.  Review Jenkins logs for pipeline errors

* * * * *

🚀 Happy Deploying! Your end-to-end CI/CD pipeline is ready to automate deployments from code to production!

*Built with ❤️ by DevOps Engineers*
