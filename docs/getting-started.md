# Getting Started with Pentagon

## Requirements
* python2 >= 2.7 [Install Python](https://www.python.org/downloads/)
* pip [Install Pip](https://pip.pypa.io/en/stable/installing/)
* git [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* Terraform >=0.9 [Install Terraform ](https://www.terraform.io/downloads.html) 
* Ansible [Install Ansible](http://docs.ansible.com/ansible/latest/intro_installation.html)
* Kubectl [Install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* Kops [Install Kops](https://github.com/kubernetes/kops#installing)

## Installation
* `pip install -e git+https://github.com/reactiveops/pentagon.git#egg=pentagon`
  * the `-e` is important to include. The next steps will fail without it.
  * May require the `python-dev` and `libffi-dev` packages on some linux distributions
  * Not necessary, but we suggest installing Pentagon into a [VirtualEnv](https://virtualenv.pypa.io/en/stable/)

## Quick Start
### Start Project
* `pentagon start-project <project-name> --aws-access-key <aws-access-key> --aws-secret-key <aws-secret-key> --aws-default-region <aws-default-region>`
  * With the above basic options set, all defaults will be set for you and unless values need to be updated, you should be able to run terraform after creating the S3 Bucket to store state (`infrastructure-bucket`).
  * Arguments may also be set using environment variable in the format `PENTAGON_<argument_name_with_underscores>`.
* `cd <project-name>-infrastructure
* `pip install -r requirements.txt`
* `source config/local/env-vars.sh`
  * sources environment variables required for the further steps. This wil be required each time you work with the infrastructure repository or if you move the repository to another location.
* `bash config/local/config/init`

### VPC Setup
This creates a VPC and private, public, and admin subnets in that VPC for non Kubernetes resources. [More](network.md)
* `cd default/vpc`
* Verify that `terraform.tfvars` has valid values
  * in some cases, the programatically determined AWS availablity zones may not exist
* `make all`


### VPN Setup
This creates a AWS instance running [OpenVPN](https://openvpn.net/) [More](vpn.md) 
* From the root of your project run `ansible-galaxy install -r ansible-requirements.yml`
* `cd default/resources/admin-environment`
* edit `env.yml` and update any values. 
  * Make sure to add the user names of those you want to be able to access the VPN. You can add more later
* edit `../../account/vars.yml` to make sure the values are corect
  * Cannonical zone must be a route53 zone you have access to create records in or the vpn creation will fail.
* `ansible-playbook vpn.yml`
  * _This will fail on the first run_
  * Copy the IP-address of the instance created and add it to the list of hosts `# for instances in admin` section of the `default/config/private/ssh_config` file. 
* Run it again: `ansible-playbook vpn.yml` 


### KOPS Usage
Pentagon used Kops to create clusters in AWS. The default layout creates two kubernetes clusters: `working` and `production`
The steps to create each cluster are identical but the paths are slightly differnt. The cluster creation scirpts are located at `default/clusters/<production|working>/cluster-config/kops.sh` (See [Overview](overview.md) for a more comprehensive description of the directory layout).

* From the directory for the cluster you wish to create (working or production) run `bash kops.sh` 
  * this script creates the cluster.spec file for our default cluster. It does not create the cluster itself.
* Use the `kops update cluster $CLUSTER_NAME` command to view and edit the `cluster.spec` and make the following edits
  * Choose approriate CIDR ranges for your Kubernetes subnets (these subnest are separate from the subnets that were created in the [VPC](#vpc-setup) step) We typically reccomend fairly small subnets ie /22 or /24.
  * For each of the subnets in the `cluster.spec` add an `egress: nat-05ee835341f099286` line to the yaml file. Through the AWS console, use the id of the nat-gateway associated with the `public_az` subnet (created above) in the same availability zone as the subnet in the `cluster.spec`
* Save and exit
* You may also wish to edit the instance group using the `kops edit $INSTANCE_GROUP` prior to cluster creation
* `kops update cluster $CLUSTER_NAME`
  * review the out put to ensure it matches the cluster you wish to create
* `source ../vars.sh && source ../../../account/vars.sh` to set the environment variables for the cluster you're working on
* `kops update cluster $CLUSTER_NAME --yes` will create the cluster
* While waiting for the cluster to create, consult the [kops documentation](https://github.com/kubernetes/kops/blob/master/docs/README.md) for more information about using kops and interacting with your new cluster

### Creating resources outside of Kubernetes

Typically infrastructure will be required outside of your Kubernetes cluster. Other EC2 isntances or RDS instance or Elasticache instances etc are often require for an application.

The directory structure of the project suggests that you use Ansible to create these resources and that the ansible playbooks can be save in the `default/resources/` direcotry or the `default/clusters/<cluster>/resoures/` directory depending on the scope the play book will be utilized. If the resoures is not specific to either cluster, then we suggest you save it at the `deault/resources/` level. Likewise, if it is a resources that will only be used by one cluster, such as a staging database or a production database, then we suggest writing the Ansible playbook at the `default/cluster/<cluster>/resources/` level. Writing ansible roles can be very helpful to DRY up your resource configurations.


======================================

## Advanced Project Initialization

If you wish to utilize the templating ability of the `pentagon start-project` command, but need to modify the defaults, a comprehensive list of command line flags, listed below, should be able to customize the outout of the `pentagon start-project` command to your liking.


### Start new project
* `pentagon start-project <project-name> <options>`
  * This will create a skeleton repository with placeholder strings in place of the options shown above in the [QUICK START]
  * Edit the `config/private/secrets.yml` and `config/local/env.yml` before proceeding onto the next step

### Clone existing project
* `pentagon start-project <project-name> --git-repo <repository-of-existing-project> <options>`

### Available commands
* `pentagon start-project`

### _start-project_

 `pentagon start-project` creates a new project in your workspace directory and creates a matching virtualenv for you. Most values have defaults that should get you up and running very quickly with a new pentagon project. You may also clone an existing pentagon project if one exists.  You may set any of these options as environment variables instead by prefixing them with `PENTAGON_`, for example, for security purposes `PENTAGON_aws_access_key` can be used instead of `--aws-access-key`

 #### Options
  * **-f, --config-file**:
    * File to read configuration options from.
    * No default
    * ***File supercedes command line options.***
  * **-o, --output-file**:
    * No default
  * **--workspace-directory**:
    * Directory to place new project
    * Defaults to `./`
  * **--repository-name**:
    * Name of the folder to initialize the infrastructure repository
    * Defaults to `<project-name>-infrastructure`
  * **--configure / --no-configure:**:
    * Configure project with default settings
    * Default to True
    * If you choose `--no-configure`, placeholder values will be used in stead of defaults and you will have to manually edit the configuration files
  * **--force / --no-force**:
    * Ignore existing directories and copy project anyway
    * Defaults to False
  * **--aws-access-key**:
    * AWS access key
    * No Default
  * **--aws-secret-key**:
    * AWS secret key
    * No Default
  * **--aws-default-region**:
    * AWS default region
    * No Default
    * If the `--aws-default-region` option is set it will allow the default to be set for `--aws-availability-zones` and `--aws-availability-zone-count`
  * **--aws-availability-zones**:
    * AWS availability zones as a comma delimited list.
    * Defaults to `<aws-default-region>a`, `<aws-default-region>b`, ... `<aws-default-region>z` when `--aws-default-region` is set calculated using the `--aws-available-zone-count` value. Otherwise, a placeholder string is used.
  * **--aws-availability-zone-count**:
    * Number of availability zones to use
    * Defaults to 3 when a default region is entered. Otherwise, a placeholder string is used
  * **--infrastructure-bucket**:
    * Name of S3 Bucket to store state
    * Defaults to `<project-name>-infrastructure`
    * pentagon start-project does not create this bucket and it will need to be created
  * **--git-repo**:
    * Existing git repository to clone
    * No Default
    * ***When --git-repo is set, no configuration actions are taken. Pentagon will setup the virutualenv and clone the repository only***
  * **--create-keys / --no-create-keys**:
    * Create ssh keys or not
    * Defaults to True
    * Keys are saved to `<workspace>/<repsitory-name>/config/private`
    * 5 keys will be created:
      * `admin_vpn`: key for the vpn instances
      * `working_kube`: key for working kubernetes instances
      * `production_kube`: key for production kubernetes instance
      * `working_private`: key for non-kubernetes resources in the working private subnets
      * `production_private`: key for non-kubernetes resources in the production private subnets
    * ***Keys are not uploaded to AWS. When needed, this will need to be done manually***
  * **--admin-vpn-key**:
    * Name of the ssh key for the admin user of the VPN instance
    * Defaults to 'admin_vpn'
  * **--working-kube-key**:
    * Name of the ssh key for the working kubernetes cluster
    * Defaults to 'working_kube'
  * **--production-kube-key**:
    * Name of the ssh key for the production kubernetes cluster
    * Defaults to 'production_kube'
  * **--working-private-key**:
    * Name of the ssh key for the working non-kubernetes instances
    * Defaults to 'working_private'
  * **--production-private-key**:
    * Name of the ssh key for the production non-kubernetes instances
    * Defaults to 'production_private'
  * **--vpc-name**:
    * Name of VPC to create
    * Defaults to date string in the format `<YYYYMMDD>`
  * **--vpc-cidr-base**
    * First two octets of the VPC ip space
    * Defaults to '172.20'
  * **--working-kubernetes-cluster-name**:
    * Name of the working kubernetes cluster nodes
    * Defaults to `working-1.<project-name>.com`
  * **--working-kubernetes-node-count**:
    * Number of the working kubernetes cluster nodes
    * Defaults to 3
  * **--working-kubernetes-master-aws-zone**:
    * Availability zone to place the kube master in
    * Defaults to the first zone in --aws-availability-zones
  * **--working-kubernetes-master-node-type**:
    * AWS instance type of the kube master node in the working cluster
    * Defaults to t2.medium
  * **--working-kubernetes-worker-node-type**:
    * AWS instance type of the kube worker nodes in the working cluster
    * Defaults to t2.medium
  * **--working-kubernetes-dns-zone**:
    * DNS Zone of the kubernetes working cluster
    * Defaults to `working.<project-name>.com`
  * **--working-kubernetes-v-log-level**:
    * V Log Level kubernetes working cluster
    * Defaults to 10
  * **--working-kubernetes-network-cidr**:
    * Network cidr of the kubernetes working cluster
    * Defaults to `172.20.0.0/16`
  * **--production-kubernetes-cluster-name**:
    * Name of the production kubernetes cluster nodes
    * Defaults to `production-1.<project-name>.com`
  * **--production-kubernetes-node-count**:
    * Number of the production kubernetes cluster nodes
    * Defaults to 3
  * **--production-kubernetes-master-aws-zone**:
    * Availability zone to place the kube master in
    * Defaults to the first zone in --aws-availability-zones
  * **--production-kubernetes-master-node-type**:
    * AWS instance type of the kube master node in the production cluster
    * Defaults to t2.medium
  * **--production-kubernetes-worker-node-type**:
    * AWS instance type of the kube worker nodes in the production cluster
    * Defaults to t2.medium
  * **--production-kubernetes-dns-zone**:
    * DNS Zone of the kubernetes production cluster
    * Defaults to `production.<project-name>.com`
  * **--production-kubernetes-v-log-level**:
    * V Log Level kubernetes production cluster
    * Defaults to 10
  * **--production-kubernetes-network-cidr**:
    * Network cidr of the kubernetes production cluster
    * Defaults to `172.20.0.0/16`
  * **--configure-vpn/--no-configure-vpn**:
    * Do, or do not configure the vpn env.yaml file
    * Defaults to True
  * **--vpn-ami-id
    * AWS ami id to use for the VPN instance
    * Defaults to looking up ami-id from AWS
  * **--log-level**:
    * Pentagon CLI Log Level. Accepts DEBUG,INFO,WARN,ERROR
    * Defaults to INFO
  * **--help**:
    * Show help message and exit.

