**THIS REPOSITORY IS NO LONGER USED! Please see [sms-compose](https://github.com/votinginfoproject/sms-compose) for information on building and deploying the VIP SMS app.**

# SMS-Infrastructure

## Description
Automate the testing & creation of Infrastructure for the VIP SMS app.

This project uses Terraform to control AWS infrastructure (ie, load balancers, so many worker nodes, security groups, etc), and ansible to create AMI images for the servers that run the web and worker processes (ie, install ruby, gems, other server infrastructure). If you need to update the base web or worker images because of new libraries or new keys, you build them with the rake tasks outlined below, get the current terraform state with the get_tfstate task, and then run the terraform rake task, and then upload the new terraform state at the end.

To deploy new versions of either the web or worker apps, you use the deploy tasks from those projects, see their readmes.

## Requirements
- [Terraform](http://www.terraform.io) 0.3
- [Vagrant](http://www.vagrantup.com)
- [Ansible](http://docs.ansible.com/intro_installation.html#getting-ansible) or `brew install ansible`
- Ruby 2.1.2
- A .env file with the following items...

~~~~
ACCESS_KEY_ID=
SECRET_ACCESS_KEY=
ENVIRONMENT={{ env }}
~~~~

## Development System Setup
To set your system up to develop this application...

1. Make sure you have everything from the requirements section
2, For terraform, download the version for your platform and add the executables to your PATH
2. Run `bundle`

## Workflows
### Modify The Web / Worker Image
1. Make modifications to the ansible script (the files in /roles), or the infrastructure recipes in infrastructure.tf.
2. Test locally using vagrant
    - Run `vagrant up` if your VMs do not exist
    - Run `vagrant reload --provision` if your VMs do exist
3. Use the rake command specified below to build new images
4. Replace the appropriate ami ids in the Infrastructure.tfvars file
5. Run `rake get_tfstate\[bucket\]` to get the latest tfstate (bucket is usually named vip-sms-terraform)
6. Run `rake terraform`
7. Run `rake upload_tfstate\[bucket\]` to upload the new tfstate

## Commands
### Run Terraform
~~~~
rake terraform
~~~~

- Run terraform apply with the AWS credentials in your .env file
- Create AWS SQS queues
- Create AWS DynamoDB databases

### Upload Latest tfstate File To S3
~~~~
rake upload_tfstate\[bucket\]
~~~~

- Unmark the previous latest terraform.tfstate file as latest
- Upload the new terraform.tfstate file marked as latest

### Get The Latest tfstate File From S3
~~~~
rake get_tfstate\[bucket\]
~~~~

- Move the current terraform.tfstate file (if it exists) to
  terraform.tfstate.old
- Download the latest terraform.tfstate file from S3

### Build New Web Image
~~~~
rake build_web_image\[environment\]
~~~~

- Spin up a new AWS EC2 instance
- Run the Ansbile script on it
- Stop the instance
- Create an AMI
- Terminate the instance

### Build New Worker Image
~~~~
rake build_worker_image\[environment\]
~~~~

- Spin up a new AWS EC2 instance
- Run the Ansbile script on it
- Stop the instance
- Create an AMI
- Terminate the instance
