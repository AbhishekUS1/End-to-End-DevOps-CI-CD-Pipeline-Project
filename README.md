```🚀 End-to-End DevOps CI/CD Pipeline Project```
Terraform | Jenkins | Docker | Kubernetes (MicroK8s) | AWS EC2 | GitHub
📌 Project Overview

This project demonstrates a complete End-to-End DevOps CI/CD pipeline that automates the deployment of a static web application using modern DevOps tools.
It covers everything from infrastructure provisioning to continuous integration, containerization, image registry management, and automated Kubernetes deployment.

This is a perfect real-world project for DevOps portfolios, interviews, and production-grade workflow demonstrations.

🏗 Architecture Diagram
Developer → GitHub Repo → Jenkins Pipeline → Docker Build → Docker Hub → MicroK8s Kubernetes → End Users
↑ ↘ Terraform (AWS EC2)

🎯 Objectives

✔ Automate the entire software delivery lifecycle
✔ Provision AWS infrastructure using Terraform
✔ Build and push Docker images automatically
✔ Deploy application to Kubernetes (MicroK8s)
✔ Enable continuous delivery with Jenkins Pipeline
✔ Ensure scalable, consistent, and repeatable environments

🧰 Tech Stack
Terraform Infrastructure as Code (AWS EC2 provisioning)
Jenkins CI/CD Orchestration
Docker Containerization
Docker Hub Image Registry
MicroK8s Lightweight Kubernetes cluster
Nginx Web server for static app
AWS EC2 Cloud compute instance

🚀 Pipeline Workflow
Developer pushes code → GitHub
Jenkins pipeline triggers automatically
Docker image is built from Dockerfile
Jenkins logs in to Docker Hub and pushes image
MicroK8s deploys latest image using deploy.yaml
Kubernetes exposes the application via NodePort
Application becomes accessible to end users

🛠 Project Structure
├── terraform/
│ └── main.tf
│
├── jenkins/
│ └── Jenkinsfile
│
├── docker/
│ ├── Dockerfile
│ └── index.html
│
├── kubernetes/
│ └── deploy.yaml
│
└── README.md

📦 Terraform Configuration (AWS EC2)

Your Terraform script provisions:

t2.medium EC2 instance

30GB GP2 volume

SSH access

Jenkins & Kubernetes-ready server

Security group rules (22, 8080, 80)

Run Terraform:

terraform init
terraform validate
terraform plan
terraform apply -auto-approve

🐳 Docker Configuration

```
Dockerfile:

FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD [“nginx”, “-g”, “daemon off;”]
```

🧪 Jenkins Pipeline (Jenkinsfile)
```
pipeline {
agent any

environment {
    DOCKER_IMAGE = 'your-dockerhub-username/test-dev:latest'
}
stages {
    stage('Clone Repository') {
        steps {
            git 'https://github.com/<your-username>/scroll-web.git'
        }
    }
    stage('Build Docker Image') {
        steps {
            sh '''
                docker build -t $DOCKER_IMAGE .
            '''
        }
    }
    stage('Login to Docker Hub') {
        steps {
            script {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-hub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    '''
                }
            }
        }
    }
    stage('Push Docker Image') {
        steps {
            sh '''
                docker push $DOCKER_IMAGE
            '''
        }
    }
    stage('Deploy to Kubernetes') {
        steps {
            sh '''
                microk8s.kubectl apply -f deploy.yaml
            '''
        }
    }
}  
}
```

☸️ Kubernetes Deployment (deploy.yaml)

```
apiVersion: apps/v1
kind: Deployment
metadata:
name: my-deploy-app
spec:
replicas: 2
selector:
matchLabels:
app: my-app
template:
metadata:
labels:
app: my-app
spec:
containers:

  - name: devops-app
    image: your-dockerhub-username/test-dev:latest
    ports:
    - containerPort: 80
apiVersion: v1
kind: Service
metadata:
name: devops-service
spec:
type: NodePort
selector:
app: my-app
ports:

protocol: TCP
port: 80
targetPort: 80
nodePort: 30326
```

📊 Verification Commands
kubectl get pods
kubectl get svc
kubectl get deployments
curl http://localhost:30326

🌐 Access the Application

Open in your browser:

http://<EC2_Public_IP>:30326

🧩 Troubleshooting

Jenkins cannot run Docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

kubectl permission issues
sudo microk8s.config > /var/lib/jenkins/.kube/config
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config

Docker login fails

Check your credentials ID:

docker-hub-credentials

📈 Key Features of This Project

✔ Fully automated CI/CD
✔ Kubernetes deployment with scaling
✔ Immutable Docker images
✔ Infrastructure as Code with Terraform
✔ Production-ready DevOps toolchain
✔ Ideal for resumes & interviews

🧠 Future Enhancements

Add GitHub Webhooks
Implement ArgoCD (GitOps)
Add Prometheus + Grafana monitoring
Add automated testing stage
Use EKS instead of MicroK8s

🏁 Conclusion

This project demonstrates a real-world DevOps CI/CD pipeline using industry-standard tools and practices.
It is a great example of automation, containerization, orchestration, and cloud infrastructure provisioning.
