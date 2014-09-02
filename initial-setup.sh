# Intiial server setup, create a user, lock down root and use only public key authentication
# Following - http://articles.slicehost.com/2010/10/18/ubuntu-maverick-setup-part-1

export EDITOR="vi"

# Create a group for admins
/usr/sbin/groupadd wheel

# Add wheel group to sudoers
visudo

# Enter the following (uncomment first)
## Allows people in group wheel to run all commands
# %wheel  ALL=(ALL) NOPASSWD: ALL

# Create a user
adduser bobby

# Add user to the wheel group for admin rights
/usr/sbin/usermod -a -G wheel bobby

# Copy ssh key from local machine to server
scp ~/.ssh/id_rsa.pub bobby@db1:

# Move the key to the right place and set permissions
mkdir ~bobby/.ssh
mv ~bobby/id_rsa.pub ~bobby/.ssh/authorized_keys
chown -R bobby:bobby ~bobby/.ssh
chmod 700 ~bobby/.ssh
chmod 600 ~bobby/.ssh/authorized_keys

# Lock down ssh config a little more
vi /etc/ssh/sshd_config

# Enter the following (uncomment first)
# Protocol 2
# PermitRootLogin no
# PasswordAuthentication no
# UseDNS no
# AllowUsers bobby

# Reload ssh
/etc/init.d/ssh reload
