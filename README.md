# terraform-example

This repo holds an example of provisioning an eks cluster with terraform, using windows machine. It will create an eks cluster, and deploy both windows and linux webserver containers to the same cluster.

Before beginning, become familiar with the steps described here to deploy a Linux-only kubernetes cluster with terraform.
https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster
https://learn.hashicorp.com/terraform/kubernetes/deploy-nginx-kubernetes

It needs a little manual intervention, but hopefully can be streamlined in the future.

packages you need from chocolatey:

```
terraform awscli aws-iam-authenticator kubernetes-cli wget jq openssl.light ekcsli
```

To begin, run these two commands:

```
terraform init
terraform apply
```

terraform apply should create almost everything, but it won't be able to finish creating the windows deployment, because the windows support pods aren't running on the cluster yet.

Starting the windows support pods is described here (the batch script below will implement what is described):
https://docs.aws.amazon.com/eks/latest/userguide/windows-support.html
https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md#how-can-i-use-windows-workers


Ctrl-c out of the hanging terraform apply, and run

```
eksctl get clusters
```

To figure out the name of the new cluster. Paste it into this command to get kubectl working.

```
aws eks --region us-east-2 update-kubeconfig --name <name from output>
```

run this to do what is described on the AWS website

```
enable_windows_commands.bat
```

That should kick off the pods on the cluster necessary for running windows pods. The vpc-admission-webhook and vpc-resource controller pods need to be restarted with a command similar to this:

```
kubectl --namespace kube-control delete pod vpc-admission-webhook-deployment-579c976c68-9t7rv vpc-resource-controller-764c979649-49xhx
```

Needing to restart was suggested here:
https://github.com/aws/containers-roadmap/issues/463

Before running terraform apply again, you may need to delete the win-example deployment if it is running, so terraform doesn't bail.

```
kubectl delete deployment win-example
```

Now, you should be able to run:

```
terraform apply
```

and it should finish successfully.
This is what it looks like when everything is running.

```
kubectl get deployments --all-namespaces
NAMESPACE     NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
default       scalable-nginx-example             1/1     1            1           44m
default       win-example                        1/1     1            1           27m
kube-system   coredns                            2/2     2            2           47m
kube-system   vpc-admission-webhook-deployment   1/1     1            1           36m
kube-system   vpc-resource-controller            1/1     1            1           36m

kubectl get services --all-namespaces
NAMESPACE     NAME                        TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)         AGE
default       kubernetes                  ClusterIP      172.20.0.1       <none>                                                                    443/TCP         47m
default       nginx-example               LoadBalancer   172.20.79.170    a6e79fc0919384bcb8944cacdd1b00f3-1918390455.us-east-2.elb.amazonaws.com   80:32436/TCP    43m
default       win-example                 LoadBalancer   172.20.155.181   aefdfafefe777418f957f1a819cc1a1b-329534598.us-east-2.elb.amazonaws.com    80:32150/TCP    27m
kube-system   kube-dns                    ClusterIP      172.20.0.10      <none>                                                                    53/UDP,53/TCP   47m
kube-system   vpc-admission-webhook-svc   ClusterIP      172.20.137.35    <none>                                                                    443/TCP         36m

kubectl get pods --all-namespaces
NAMESPACE     NAME                                                READY   STATUS    RESTARTS   AGE
default       scalable-nginx-example-68867b7bf7-9cd2v             1/1     Running   0          44m
default       win-example-844745fc4c-vsvhb                        1/1     Running   0          28m
kube-system   aws-node-2vjbh                                      1/1     Running   0          44m
kube-system   aws-node-68dmh                                      1/1     Running   0          44m
kube-system   coredns-bd44f767b-6nq7p                             1/1     Running   0          47m
kube-system   coredns-bd44f767b-kw6gh                             1/1     Running   0          47m
kube-system   kube-proxy-h45cp                                    1/1     Running   0          44m
kube-system   kube-proxy-p58xd                                    1/1     Running   0          44m
kube-system   vpc-admission-webhook-deployment-579c976c68-9t7rv   1/1     Running   0          34m
kube-system   vpc-resource-controller-764c979649-49xhx            1/1     Running   0          34m
```

After a few minutes, you should be able to access both webservers using the EXTERNAL-IP of the services in your web browser.
