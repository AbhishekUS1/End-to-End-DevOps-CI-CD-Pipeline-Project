📌 Project Overview
This project demonstrates a complete End-to-End DevOps CI/CD pipeline that automates the deployment of a static web application using modern DevOps tools. It covers everything from infrastructure provisioning to continuous integration, containerization, image registry management, and automated Kubernetes deployment.

This is a perfect real-world project for DevOps portfolios, interviews, and production-grade workflow demonstrations.

🏗 Architecture Diagram

 Developer → GitHub Repo → Jenkins Pipeline → Docker Build → Docker Hub → MicroK8s Kubernetes → End Users
                     ↑                   ↘ Terraform (AWS EC2)
🎯 Objectives
✔ Automate the entire software delivery lifecycle

✔ Provision AWS infrastructure using Terraform

✔ Build and push Docker images automatically

✔ Deploy application to Kubernetes (MicroK8s)

✔ Enable continuous delivery with Jenkins Pipeline

✔ Ensure scalable, consistent, and repeatable environments

🧰 Tech Stack
Tool	Purpose
Terraform	Infrastructure as Code (AWS EC2 provisioning)
Jenkins	CI/CD Orchestration
Docker	Containerization
Docker Hub	Image Registry
MicroK8s	Lightweight Kubernetes cluster
Nginx	Web server for static app
AWS EC2	Cloud compute instance
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
│   └── main.tf
│
├── jenkins/
│   └── Jenkinsfile
│
├── docker/
│   ├── Dockerfile
│   └── index.html
│
├── kubernetes/
│   └── deploy.yaml
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

Dockerfile:
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
🧪 Jenkins Pipeline (Jenkinsfile)
Copy
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

☸️ Kubernetes Deployment (deploy.yaml)
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
---
apiVersion: v1
kind: Service
metadata:
  name: devops-service
spec:
  type: NodePort
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 30326

📊 Verification Commands
kubectl get pods
kubectl get svc
kubectl get deployments
curl http://localhost:30326

🌐 Access the Application
Open in your browser:
http://<EC2_Public_IP>:30326

🧩 Troubleshooting
1. Jenkins cannot run Docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

2. kubectl permission issues
sudo microk8s.config > /var/lib/jenkins/.kube/config
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config
3. Docker login fails
Check your credentials ID:

Copy
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
This project demonstrates a real-world DevOps CI/CD pipeline using industry-standard tools and practices. It is a great example of automation, containerization, orchestration, and cloud infrastructure provisioning.

If you like this project, ⭐ star the repository!

Feel free to let me know if you need any additional modifications or enhancements!

sam@DESKTOP-VUMFB8H:~/devops-cicd-project$ git push -u origin main
error: src refspec main does not match any
error: failed to push some refs to 'https://github.com/AbhishekUS123/devops-cicd-project.git'

Monica
GPT-4o mini
The error message you're encountering indicates that Git cannot find the branch named main in your local repository. This can happen for a couple of reasons. Here are some steps to troubleshoot and resolve this issue:

1. Check Current Branch
First, check which branch you are currently on by running:

Copy
git branch
If you see an asterisk (*) next to another branch (like master), it means you are not on the main branch.

2. Create or Switch to the Main Branch
If you want to push to the main branch and it doesn't exist yet, you can create it:

Copy
git checkout -b main
If the main branch already exists but you're on a different branch, switch to it:

Copy
git checkout main
3. Add and Commit Changes
If you have made changes that need to be committed, make sure to add and commit them:

Copy
git add .
git commit -m "Your commit message"
4. Push to Remote Repository
Now, try pushing to the main branch again:

Copy
git push -u origin main
5. Verify Remote Branches
If you still face issues, check the branches available on the remote repository:

Copy
git fetch origin
git branch -r
This will show you the remote branches. If origin/main does not exist, you may need to confirm the default branch name used in your GitHub repository. Sometimes it might be master instead of main.

6. Pushing to Master
If your repository uses master instead of main, you can push to master like this:

Copy
git push -u origin master
Summary
By following these steps, you should be able to resolve the issue with pushing to your GitHub repository. If you continue to have problems, please provide additional information about your current branch and any recent changes you've made.
