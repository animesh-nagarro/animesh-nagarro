# AWS EKS GitOps Project

This repository scaffolds an end-to-end GitOps demo that mirrors the original Azure assignment but implemented on **AWS**.

---

## Prerequisites

* AWS CLI installed and configured with an IAM user/role that has sufficient permissions.
* Terraform installed.
* kubectl installed.
* Helm installed.
* Azure DevOps project with access to your repo.
* Self-hosted Azure DevOps agent VM provisioned by Terraform.

---

## Step 1: Provision Infrastructure with Terraform

```bash
cd terraform/global
terraform init
terraform apply -auto-approve

cd ../vpc
terraform init
terraform apply -auto-approve

cd ../eks
terraform init
terraform apply -auto-approve

cd ../ecr
terraform init
terraform apply -auto-approve

cd ../agent_vm
terraform init
terraform apply -auto-approve
```

This creates:

* VPC with subnets.
* EKS cluster with system and user node groups.
* ECR repositories for `web` and `api`.
* Ubuntu EC2 VM for self-hosted DevOps agent.

Verify access:

```bash
aws eks update-kubeconfig --region <region> --name <cluster_name>
kubectl get nodes
```

---

## Step 2: Deploy AWS Controllers

Install EFS CSI Driver (for RWX volumes):

```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.5"
```

Install AWS Load Balancer Controller (for Ingress):

```bash
helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster_name> \
  --set serviceAccount.create=false \
  --set region=<region> \
  --set vpcId=<vpc_id>
```

---

## Step 3: Install Argo CD

```bash
kubectl apply -n argocd -f argocd/install/namespace.yaml
kubectl apply -n argocd -f argocd/install/install.yaml
```

Or via Helm:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  -f argocd/install/values.yaml
```

Retrieve initial password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

Login to Argo CD UI at the LoadBalancer/Ingress address.

---

## Step 4: Configure Azure DevOps Pipeline

The provided `azure-pipelines.yml`:

* Builds and pushes Docker images for `web` and `api` to ECR.
* Updates Helm chart values with new tags.
* Commits and pushes changes so Argo CD syncs automatically.

Steps:

1. Create a new pipeline in Azure DevOps pointing to this repo.
2. Assign the pipeline to run on the self-hosted agent (`self-hosted-aws-agent`).
3. Add AWS credentials to the agent or via pipeline variables.

Trigger the pipeline:

* On push to `main` branch.
* Or manually.

---

## Step 5: Deploy Applications with Helm + Argo CD

Argo CD will automatically sync the `helm-chart` from the repo.

Verify:

```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```

---

## Step 6: Test the Apps

* Access `http://<ingress-host>/` → should return **Hello from Web!**
* Access `http://<ingress-host>/api/healthz` → should return `{ "status": "ok" }`
* Upload file:

```bash
curl -F "file=@test.txt" http://<ingress-host>/api/upload
```

Restart the API pod:

```bash
kubectl delete pod <api-pod-name>
```

Uploaded file should still exist under `/data` in the new pod (PVC persistence).

---

## Step 7: Operations & Debugging

* Check logs:

```bash
kubectl logs -f deployment/web
kubectl logs -f deployment/api
```

* Describe pods/services:

```bash
kubectl describe pod <pod>
kubectl describe svc api
```

* Roll back with Argo CD UI or CLI:

```bash
argocd app rollback demo-app <revision>
```

---

## Deliverables Recap

* **Terraform** → VPC, EKS, ECR, agent VM.
* **Helm Chart** → web, api, PVC, ingress.
* **Azure DevOps Pipeline** → builds, pushes, updates values.
* **Argo CD Application** → GitOps deployment.
* **Persistence** → uploads survive pod restarts via EFS PVC.
* **Ingress** → `/` → web, `/api/healthz` → api.

(Bonus) TLS can be added via cert-manager + ACM.
