# terraform-example

terraform init
terraform apply
the output of lb_ip is an accesible web address 

NOTE: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#how-can-i-use-windows-workers
to use windows workers, you have to create a linux cluster, apply manual commands to enable windows features, then modify your cluser to have windows nodes.



To make kubectl usable:
aws eks --region us-east-2 update-kubeconfig --name <name from output>


Requirements:
awscli, aws-iam-authenticator, kubernetes-cli, wget, jq, openssl.light

https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster
https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes#schedule-a-service
