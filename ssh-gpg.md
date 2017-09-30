## ssh

1. `$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`
2. `$ eval $(ssh-agent -s)`
3. `$ ssh-add ~/.ssh/id_rsa`
4. `$ clip < ~/.ssh/id_rsa.pub`
5. Add ssh key to github using web interface
6. `$ ssh -T git@github.com`

## gpg

