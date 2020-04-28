## /etc/ansible/hosts
```
[all:vars]
ansible_user=USER
ansible_sudo_pass=PASS
ansible_python_interpreter='/usr/bin/env python3'

[workstation]
192.168.1.45

[unifi]
192.168.1.23

[docker]
192.168.1.24
192.168.1.45
```

## ./ansible-update.yml
```
---
- hosts: all
  name: update apt
  become: true
  become_method: sudo
  tasks:
  - name: apt update
    apt:
      update_cache: yes
      force_apt_get: yes
      cache_valid_time: 3600

  - name: apt upgrade
    apt:
      upgrade: dist
      force_apt_get: yes

  - name: remove old packages
    apt:
      autoclean: yes
      autoremove: yes
      force_apt_get: yes

  - name: check for reboot required
    register: reboot_required_file
    stat: path=/var/run/reboot-required get_md5=no

  - name: Reboot if kernel updated
    reboot:
      msg: "Reboot initiated by Ansible for kernel updates"
      connect_timeout: 5
      reboot_timeout: 300
      pre_reboot_delay: 0
      post_reboot_delay: 30
      test_command: uptime 
    when: reboot_required_file.stat.exists

- hosts: docker
  name: update docker
  tasks:
  - name: update docker containers
    docker_compose:
      project_src: /home/USER/
      pull: yes
    register: output

#  - debug:
#      var: output

  - name: remove orphaned containers
    docker_compose:
      project_src: /home/USER/
      remove_orphans: yes
```

## ansible_deploy_keys.yml
```
---
- hosts: all
  name: deploy keys
  become: true
  become_method: sudo
  tasks:
  - name: deploy ssh ed25519 keys from github
    authorized_key:
      user: USER
      state: present
      key: https://github.com/USER.keys
      exclusive: True
```
