# ☁️ AWS Terraform Infrastructure Project

This project provisions a full AWS infrastructure using Terraform, including:

### 🚧 Infrastructure Components
- 🌐 VPC with Public & Private Subnets (2 AZs)
- 🔐 Internet Gateway + NAT Gateway
- 🛡️ Security Groups and NACLs
- 🖥️ 2 EC2 Instances (with Apache + Resume page)
- ⚖️ Application Load Balancer (ALB)
- 🗄️ RDS MySQL Instance (Private Subnet)
- 🌍 Optional: Route 53 DNS Ready
- 🔑 Key Pair for SSH access

---

### 🧾 Resume Page Features
- 🖤 Dark theme HTML resume auto-deployed on both EC2s
- 👨‍💻 Includes About, Skills, Projects, Contact Form (static)
- 🌐 Accessible via Load Balancer DNS

---

### 🔧 Tools Used
- 🧰 Terraform
- 🖥️ AWS EC2, VPC, RDS, ALB
- 🐧 Amazon Linux
- 💻 MobaXterm for SSH
- 🎨 HTML/CSS for UI

---

### 📷 Architecture Diagram

> ![AWS Infra Diagram](insert-your-architecture-image-url-here)
![arcture](https://github.com/user-attachments/assets/5a4d10c2-7beb-470c-9f61-e1e2ee397566)

---

### 🚀 How to Deploy

```bash
git clone https://github.com/your-username/aws-terraform-project.git
cd aws-terraform-project
terraform init
terraform apply
