# devops

The old version of CI/CD and IAC is available [here](https://github.com/CPTMUTCHELL/cbr-currency-converter/tree/old-ci/cd)

### IAC

1. Terraform. I use it to get resources the next resources from GCP:
   * VM for Jenkins and VM for Kubernetes cluster
   * Ports setup
   * A-record for the cluster
   Before running terraform, enable Cloud Resource Manager API in GCP. [issue link](https://github.com/hashicorp/terraform-provider-google/issues/6101) and create a GCP Service Account for Terraform.

   Run `terraform init` and `terraform apply -var-file="variables.tfvars"` to get GCP resources
2. Ansible. Used for Kubernetes cluster, Jenkins configuration and flux. Quick review:
   * jenkins_setup role:
      Runs Jenkins in docker via docker-compose. You can configure plugins you need and git web-hooks for your repositories. Check jenkins-casc.yaml for pre-installation setup
   * k8s_setup role:
      Installs k3s, Helm, It was used to generate a separate kubeconfig for Jenkins, but now it's different approach (gitops) :) 
   * manifest_handler role
      Applies k8s resources and installs and configures Metallb (Load balancer), Postgres, RabbitMQ, Traefik (reverse-proxy + tls) and Fluxcd

#### Components installed: 
* Metallb: Used to provide external load balancer to the cluster. It opens the cluster for traffic. 
* Traefik: It routes traffic to applications as Ingress controller/reverse-proxy. As a bonus it gets TLS certificates from Let's Encrypt :) 
Dashboard is also available. To generate the password use this command: `htpasswd -nb login password | base64` When I had different subdomains for backend and frontend I had this problem [issue link](https://github.com/traefik/traefik/issues/3414). One of the solutions was to scale down and then scale up a frontend service
* PostgreSQL: Applications inside cluster can access it by its service name
* RabbitMQ: Dashboard is available. Had to google a lot here :) I used tls from Traefik, but not from rabbitmq chart.

Please, follow my Ansible tasks and templates folder in manifest_handler. It contains chart values and kubernetes manifests

Fill variables with your parameters. For secrets use `ansible-vault`
Run playbooks `ansible-playbook k3s-helm-playbook.yml --ask-vault-pass` and `ansible-playbook jenkins-playbook.yml --ask-vault-pass`


### GitOps

1. Charts. Contains Helm charts of my applications. ConfigMaps are stored in config folder. The first group by '-' defines a namespace. For example thr first group by '-' in cbr-auth-cm.yml is cbr
2. Fluxcd. Used for Gitops approach. It scans a docker registry, updates tags and installs new version to cluster. In my case it upgrades helm releases. The advantage is that you don't provide access to your Kubernetes cluster to CI and image information, like tags, is displayed in Git