# ansible cluster provisioning

This is a basic ansible-playbook to provision your cluster of servers, it provides a good scailable starting point for hosting your Ruby applications.

1. Load balancer setup
2. Application server setup
3. Database server setup

## Example usage

First up run through the individual steps in `initial-setup.sh` to lock down your servers to a single user with rsa key access

Edit all of the files in `./vars` to your requirements.

Copy `./hosts.example` to `./hosts` and enter the details of your hosts.

```sh
# Ping the hosts to see if they respond
$ ansible -m ping -i hosts all

# List hosts that roles will run against
$ ansible-playbook -i hosts cluster.yml --list-hosts

# Run the full playbook
$ ansible-playbook -i hosts cluster.yml

# Running ad hoc commands - http://docs.ansible.com/intro_adhoc.html
```

* * *

## Roles

### (All hosts) Common

- Sets locale to en_GB.UTF8

### (load balancers) Varnish

- Installs varnish
- Provides a decent starting point configuration

### (app servers) Ruby

- Installs Ruby 2.1 package

### (app servers) nginx-passenger

- Installs nginx
- Removes default site
- Adds some global configs that can be included in your site configs
- Installs phusion passenger for use with nginx

### (db servers) postgres

- Installs postgres 9.3
- Locks down pg_hba.conf

> N.B update your private IP into `templates/postgresql.conf.j2` and update any private IPs you want to have access to the postgreSQL instance in `templates/pg_hba.conf.j2`

### nginx

- Installs standalone nginx

### haproxy

- Installs haproxy


## TODO

- Add ipconfigs for all servers
- add fail2ban with basic config
