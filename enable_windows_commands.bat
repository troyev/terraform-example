kubectl apply -f https://amazon-eks.s3.us-west-2.amazonaws.com/manifests/us-east-2/vpc-resource-controller/latest/vpc-resource-controller.yaml
curl -o vpc-admission-webhook-deployment.yaml https://amazon-eks.s3.us-west-2.amazonaws.com/manifests/us-east-2/vpc-admission-webhook/latest/vpc-admission-webhook-deployment.yaml
curl -o Setup-VPCAdmissionWebhook.ps1 https://amazon-eks.s3.us-west-2.amazonaws.com/manifests/us-east-2/vpc-admission-webhook/latest/Setup-VPCAdmissionWebhook.ps1
curl -o webhook-create-signed-cert.ps1 https://amazon-eks.s3.us-west-2.amazonaws.com/manifests/us-east-2/vpc-admission-webhook/latest/webhook-create-signed-cert.ps1
curl -o webhook-patch-ca-bundle.ps1 https://amazon-eks.s3.us-west-2.amazonaws.com/manifests/us-east-2/vpc-admission-webhook/latest/webhook-patch-ca-bundle.ps1
powershell ./Setup-VPCAdmissionWebhook.ps1 -DeploymentTemplate ".\vpc-admission-webhook-deployment.yaml"
