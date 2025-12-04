🚀 End-to-End CI/CD Pipeline for Kubernetes Deployment Using AWS, Terraform, Jenkins, Docker & MicroK8s
A complete end-to-end CI/CD pipeline for deploying a web application on Kubernetes using **AWS**, **Terraform**, **Jenkins**, **Docker**, **DockerHub**, and **MicroK8s**.  
This project demonstrates modern DevOps practices including **Infrastructure as Code (IaC)**, **containerization**, **continuous integration**, and **automated deployment**.

## ✨ Key Features

- **Infrastructure as Code:** Automated AWS EC2 provisioning with Terraform
- **Complete CI/CD Pipeline:** Jenkins automates build, test & deployment
- **Containerization:** Docker-based application packaging
- **Kubernetes Deployment:** Scalable orchestration with MicroK8s
- **Automated Workflow:** Zero-touch deployment on code changes
- **Version Control:** All infrastructure & application code tracked in Git

---


## 🚀 Quick Start Guide

### 🔧 Prerequisites
- AWS Account with IAM credentials
- Terraform ≥ 1.0
- AWS CLI configured
- DockerHub account
- GitHub repository access
---

## Step 1: Infrastructure Provisioning (Terraform)

### **main.tf**

```hcl
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0dee22c13ea7a9a67"
  instance_type = "t2.medium"
  key_name      = "project-1"

  vpc_security_group_ids = ["sg-xxxxxxxx"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }

  tags = {
    Name        = "Jenkins-CI-CD-Server"
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
```
### Apply Terraform
```hcl
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

### Step 2: EC2 Server Setup Script
```hcl
#!/bin/bash
sudo yum update -y
sudo yum install -y java-11-openjdk-devel
```

### Jenkins
```hcl sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

### Docker
```hcl sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker ec2-user
```

### MicroK8s
```hcl
sudo snap install microk8s --classic
sudo usermod -a -G microk8s ec2-user
sudo microk8s status --wait-ready
sudo microk8s enable dns registry dashboard
```

### kubectl
```hcl
sudo snap install kubectl --classic

echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
source ~/.bashrc

echo "Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
### Step 3: Dockerfile
```hcl
FROM nginx:alpine
LABEL maintainer="Your Name <your.email@example.com>"
LABEL version="1.0"
LABEL description="Nginx web server for scroll-web application"

COPY index.html /usr/share/nginx/html/index.html
COPY assets/ /usr/share/nginx/html/assets/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```
### Step 4: Jenkins Pipeline (Declarative)
```hcl
pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE = 'yourusername/scroll-web'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        K8S_NAMESPACE = 'scroll-web'
        K8S_DEPLOYMENT = 'scroll-web-deployment'
    }

    stages {
        stage('Clone Repository') {
            steps {
                checkout scm
                echo "Repository cloned successfully"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:latest .
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                  usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                  )
                ]) {
                    sh """
                    echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                kubectl set image deployment/${K8S_DEPLOYMENT} \
                web-app=${DOCKER_IMAGE}:${DOCKER_TAG} -n ${K8S_NAMESPACE} --record
                kubectl rollout status deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE}
                """
            }
        }
    }
}
```
### Step 5: Kubernetes Deployment (deploy.yaml)
```hcl
apiVersion: v1
kind: Namespace
metadata:
  name: scroll-web
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scroll-web-deployment
  namespace: scroll-web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scroll-web
  template:
    metadata:
      labels:
        app: scroll-web
    spec:
      containers:
      - name: web-app
        image: yourusername/scroll-web:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: scroll-web-service
  namespace: scroll-web
spec:
  type: NodePort
  selector:
    app: scroll-web
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30326
```
### 🔧 Configuration Guide
```hcl
AWS CLI
aws configure
```
###MicroK8s Access
```hcl
microk8s config > ~/.kube/config
kubectl get nodes
kubectl get pods -A
```
### 📊 Monitoring & Logging
```hcl
kubectl logs -f deployment/scroll-web-deployment -n scroll-web
kubectl get pods -n scroll-web -w
kubectl describe service scroll-web-service -n scroll-web
```

### 🔗 Access Application
```hcl

Local	Access: http://localhost:30326
Remote Access: http://<EC2_PUBLIC_IP>:30326
Kubernetes Dashboard:	microk8s dashboard-proxy
```
### 🎯 Conclusion
```hcl
This project showcases a modern DevOps workflow integrating:

Infrastructure automation

CI/CD orchestration

Containerization & registry management

Kubernetes deployment automation
```
