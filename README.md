# nixos-config

These are the configuration files of my system, except a few secrets
like VPN certificates, and my hashed passwords.

## Usage
I manage these files by running `source start.sh`. It keeps the `.git`
directory where you left it, sets a couple magic variables, and takes
you to `/etc/nixos`, where your `git` commands will manage the files
_in that directory_.

This is a bit of magic, so be careful. Not sure I'd recommend this
to anyone else.

### Usage Example

```
➜  nixos-config git:(master) ✗ pwd
/home/grahamc/projects/nixos-config

➜  nixos-config git:(master) ✗ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
	deleted:    .gitignore

Untracked files:
	README.md
	start.sh

no changes added to commit

➜  nixos-config git:(master) ✗ source start.sh

➜  nixos git:(master) ✗ pwd
/etc/nixos

➜  nixos git:(master) ✗ git status
On branch master
Your branch is up-to-date with 'origin/master'.

➜  nixos git:(master) ✗ ls
configuration.nix
openvpn-server-clarify-prod
desktop-gnome.nix
desktop-i3.nix
user-grahamc-passwordfile
user-root-passwordfile
hardware-configuration.nix
yubikey.nix
openvpn.nix

➜  nixos git:(master) ✗ sudo rm yubikey.nix
[sudo] password for grahamc:

➜  nixos git:(master) ✗ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes not staged for commit:
	deleted:    yubikey.nix

no changes added to commit

➜  nixos git:(master) ✗ ls
configuration.nix
openvpn.nix
desktop-gnome.nix
openvpn-server-clarify-prod
desktop-i3.nix
user-grahamc-passwordfile
hardware-configuration.nix
user-root-passwordfile

➜  nixos git:(master) ✗ git checkout yubikey.nix
error: unable to create file yubikey.nix (Permission denied)
# This doesn't work because of permissions

➜  nixos git:(master) ✗ sudo git checkout yubikey.nix
fatal: Not a git repository (or any of the parent directories): .git
# sudo doesn't work because of the magic enviroment variables

➜  nixos git:(master) ✗ sudo cp ~grahamc/projects/nixos-config/yubikey.nix .

➜  nixos git:(master) ✗ git status
On branch master
Your branch is up-to-date with 'origin/master'.
```
