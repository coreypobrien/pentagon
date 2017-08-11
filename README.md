Cookie Cutter Version!

Try with

`cookiecutter 'https://github.com/reactiveops/pentagon.git' -c pc/cookies`


# Pentagon

Pentagon is a framework for repeatable, containerized, cloud-based infrastructures (current state is beta). It defines the tools ([Ansible](https://www.ansible.com/), [Terraform](https://www.terraform.io/), [kops](https://github.com/kubernetes/kops)) used to manage the resources, as well as the directory structure of the infrastructure-as-code repository that manages those resources. It is designed to be customizable while at the same time built with defaults that fit the needs of most web application companies.

Pentagon defines an ecosystem composed of core (this repository), and other compatible modules, including dependencies such as terraform-vpc, Ansible roles like the ones defined in [ansible-requirements](lib/pentagon/ansible-requirements.txt), and [rok8s-scripts](https://github.com/reactiveops/rok8s-scripts).

It is “batteries included”- not only does one get a network with a cluster, but the defaults include these commonly desired features:

- At the core, powered by Kubernetes. Configured to be highly-available: masters and nodes are clustered
- Segregated multiple development / non-production environments
- VPN-based access control
- Centralized logging and log viewing via ES/fluentd/Kibana
- Autoscaling (up/down of both nodes and containers)
- A highly-available network, built across multiple Availability Zones
- An automated CI/CD pipeline, including application secret management
- Infrastructural monitoring

Upcoming on the [1.x Roadmap](docs/roadmap-1x.md):

- Secrets management in the cluster
- CLI tool to manage IAAC
- Metrics
- Deployment management

Take a look at [Getting Started](docs/getting-started.md) to begin.

## Vision

Pentagon exists to enable:
- Building world class cloud infrastructure quicker
- Feature-full infrastructure to be more widely available
- Small teams have access to the collective knowledge of a team of very senior infrastructure architect's opinions on best practices.

If contributed work does not work to accomplish these goals, it is not consistent with the vision of Pentagon.
