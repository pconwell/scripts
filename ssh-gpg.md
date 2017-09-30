## ssh

1. `$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`
2. `$ eval $(ssh-agent -s)`
3. `$ ssh-add ~/.ssh/id_rsa`
4. `$ clip < ~/.ssh/id_rsa.pub`
5. Add ssh key to github using web interface
6. `$ ssh -T git@github.com`

## gpg

1. `$ gpg --key-gen`
    - RSA and RSA
    - 4096
    - 0
    - pconwell
    - email
    - 
    - 
2. `$ gpg --list-secret-keys --keyid-format LONG`
    - copy the GPG key ID (the `sec` line) excluding `4096R/ `
3. `$ gpg --armor --export [key ID from above]`
4. Copy from `-----BEGIN PGP PUBLIC KEY BLOCK-----` to `-----END PGP PUBLIC KEY BLOCK-----`
5. Add key to github using web interface
6. `$ git config --global user.signingkey [key from step #2]`
7. `$ git config --global commit.gpgsign true` (optional: to sign ALL commits\*)

\* This is frowned upon. The 'correct' way is to only sign important commits, tags, releases, etc. The proper way is to use `$ git commit -S -m "your commit message"`, however I honestly don't see it as an issue and I'm lazy so I prefer to just sign everything.
