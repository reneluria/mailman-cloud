mailman @ Infomaniak Public Cloud
=================================

Intro
-----

[Mailman, the GNU Mailing List Manager](https://www.list.org/) is free software for managing electronic mail discussion and e-newsletter lists.is a mailing list

This is a guide to set it up using [Infomaniak Public Cloud](https://infomaniak.com/gtl/hosting.public-cloud) and [Infomaniak Email Service](https://www.infomaniak.com/en/hosting/service-mail/).

On a classic install, you have to tweak the mail server at your domain to pipe emails to mailman. Here we use a method to have only one email account and fetchmail to deliver to mailman.

Installation
------------

### Services

First we need openstack credentials that we obtain after project creation at Infomaniak

Then, an Email Service for a domain, and an email address

Here we will create an email address for mailman and a list "mylist":

mailman@yourdomain

and add the aliases here:

- postorius
- mylist
- mylist-bounces
- mylist-confirm
- mylist-join
- mylist-leave
- mylist-owner
- mylist-request
- mylist-subscribe
- mylist-unsubscribe

Note the email account password to use afterwards

### Infrastructure

Let's use [Terraform](https://www.terraform.io/) with the [OpenStack Provider](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs) to create Vm, security group & all

```
❯ cd terraform
```

Init terraform to download provider plugins

```
❯ terraform init

Initializing the backend...
(...)
Terraform has been successfully initialized!
```

Source your openstack credentials and then:

```
❯ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:
(...)
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

(...)

Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

ipv4_address = "xxx.xxx.xxx.xxx"
ipv6_address = "[2001:1600:xx:xx::xxxx]"

```

There we go, machine set up, use one of the two IP addresses here in the inventory file

```
❯ cd ..
```

### Setup

Let's configure everything with [Ansible](https://docs.ansible.com/ansible/latest/user_guide/).

Create an inventory file called `inventory` using example

```ini
mailman ansible_host=xxx.xxx.xxx.xxx

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=debian
ansible_ssh_private_key_file=id_tf_keypair
fqdn=mailman.<yourdomain>
mail_host=mail.infomaniak.com
mail_account=mailman@<yourdomain>
mail_password=<email_password>
mailman_user=mailman
mailman_password==<interface_password>
mailman_domain=parano.ch
mailman_email=<your_email>
```

You need to replace <> elements by the real values.

- interface_password is used to connect to the web interface
- mailman_email is your own email address

Launch playbook to configure it all

```
❯ ansible-playbook playbook.yml -D

PLAY [install mailman] *****************************************************************************************************************************************************************************************************************
(...)

PLAY RECAP *****************************************************************************************************************************************************************************************************************************
mailman                    : ok=19   changed=17   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### Usage

Log in to the interface http://[2001:1600:x:x::xxx]/mailman3 with the mailman login and password you defined in the inventory

-> Create a domain
-> Create a list "mylist"

Done :)
