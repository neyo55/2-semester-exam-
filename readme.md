
# Vagrant Setup 

This is a basic setup script to create a Vagrant environment for a master-slave configuration. The master VM is set up with a Lamp stack using the `lamp.sh` script, and the slave VM is configured with Ansible to run a playbook called `laravel.yml`. The Vagrant environment is defined in a `Vagrantfile`.

## Prerequisites

Before running this script, make sure you have the following prerequisites installed on your system:

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/) (as the provider for Vagrant)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (for provisioning the slave VM with `laravel.yml`)
- The `lamp.sh` script for provisioning the master VM.

## Lamp script
The lamp.sh script is used to install a LAMP stack on an Ubuntu 18.04 server. It includes components such as
Apache2, PHP8.2 and MySQL. 

### The following applications must be installed and configured 
- Apache2 webserver
- PHP and dependencies
- MySQL and user details configuration
- Composer
- git clone repository link

## Instructions

1. Save the script as a file, for example, `setup.sh`.

2. Make the script executable by running the following command in your terminal:

   ```bash
   chmod +x setup.sh
   ```

3. Run the script using the following command:

   ```bash
   ./setup.sh
   ```

4. The script will create a `Vagrantfile` and configure the master and slave VMs.

5. To start the Vagrant environment, execute the following command:

   ```bash
   vagrant up
   ```

## Vagrantfile Configuration

The Vagrantfile created by the script configures the Vagrant environment with two VMs: master and slave. Here's an overview of the configuration:

### Master VM

- **Box**: The master VM is based on the "bento/ubuntu-22.04" box.
- **Hostname**: The hostname is set to "master."
- **Network Configuration**: The master VM is assigned a static IP address of "192.168.56.40" on a private network.
- **Provider**: The provider is set to VirtualBox with 1GB of RAM and 1 CPU core.
- **Provisioning**: The `lamp.sh` script is executed on the master VM.

### Slave VM

- **Box**: The slave VM is also based on the "bento/ubuntu-22.04" box.
- **Hostname**: The hostname is set to "slave."
- **Network Configuration**: The slave VM is assigned a static IP address of "192.168.56.41" on a private network.
- **Provider**: The provider is set to VirtualBox with 1GB of RAM and 1 CPU core.
- **Provisioning**: Ansible is used to provision the slave VM with the `laravel.yml` playbook, and an inventory file located at "/home/neyo55/Desktop/confirmed/inventory.ini" is provided.
- The ansible.cfg file is also configured and available in the root directory where the execution took place.

## Ansible Playbook (laravel.yml)
The following Ansible playbook, laravel.yml, is used to provision the slave VM:

yaml
Copy code
---
- name: Execute Bash Script and Verify Laravel Page Accessibility
  hosts: slave
  user: vagrant
  become: yes

  tasks:
    - name: Copy the Bash Script to the Slave Node
      copy:
        src: ./lamp.sh
        dest: /tmp/lamp.sh
        mode: 0755

    - name: Edit the script before execution
      replace:
        path: /tmp/lamp.sh
        regexp: '192.168.56.40'
        replace: '192.168.56.41'
        backup: yes

    - name: Execute deployment script
      shell: /tmp/lamp.sh

    - name: Set cron job to check uptime of the server every 12 am
      cron:
        name: set cron job to check uptime of the server every 12 am
        minute: "0"
        hour: "0"
        job: "uptime >> /vagrant/uptime.log"
        user: vagrant


## Starting the Vagrant Environment

Once the script has been executed and the Vagrantfile is created, you can start the Vagrant environment by running:

```bash
vagrant up
```

This will launch both the master and slave VMs and provision them according to the defined configurations.

You can access the master and slave VMs by using SSH. For example, to access the master VM, you can run:

```bash
vagrant ssh master
```

To access the slave VM, replace "master" with "slave" in the command.

That's it! You now have a Vagrant environment set up with a master-slave configuration ready for your use.

Check the files listed in this directory to understand the whole setup better.