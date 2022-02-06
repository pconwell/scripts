## set up vscode devcontainers to use podman (instead of docker / docker desktop)
> there are like a billion different ways you can set this up, so there is a good possibility it might not work for *your* setup  
> this assumes you already had docker desktop and vscode devcontainers working (also assumes default debian wsl container)

1. Uninstall docker desktop in Windows
2. Make sure you have wsl2 up and running
3. Using powershell (or whatever terminal) in Windows, run `wsl` to go into the Windows Subsystem for Linux shell
4. install gnupg2 `sudo apt install gnupg2`
5. Add podman repo `sudo echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list`
6. Add apt key for podman repo`wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/Debian_10/Release.key -O- | apt-key add -`
7. Install libseccomp2 from backports `apt-get -y -t buster-backports install libseccomp2`
8. Install podman `sudo apt update && sudo apt upgrade -y && sudo apt install podman`
9. Copy containers.conf template `cp /usr/share/containers/containers.conf /etc/containers/containers.conf` (you may want to check if it exists first before copying)
10. Edit containters.conf `sudo nano /etc/containers/containers.conf` under `[engine]`
   1.  add `events_logger = "file"`
11. Edit  sysctl.conf `nano /etc/sysctl.conf`
   1. add `net.ipv4.ip_unprivileged_port_start=0`
12. test run `podman run hello-world`. Should be no errors.
13. Add an alias in .bashrc --> `alias docker=podman`
14. Exit wsl shell
15. In VS Code (in Windows), settings --> (had to open and close VS code several times for these settings to stick):
   1. (Optional) Remote › Containers: Execute In WSLDistro --> Debian (or whatever is appropriate)
   2. Remote › Containers: Execute In WSLDistro --> checked (active)
   3. Remote › Containers: Execute In WSLDistro --> podman
16. Rebuild your container(s) and run like normal (I couldn't find a way to reuse existing containers)
