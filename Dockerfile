FROM centos:8
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf install -y python3-pip
RUN dnf -y install  less which git wget xrdp tigervnc-server sudo openldap-devel passwd dnf-plugins-core sqlite jq lsof tcpdump traceroute zip unzip gcc postgresql-devel libjpeg-devel openssl-devel gcc-c++
RUN dnf config-manager --set-enabled PowerTools 

RUN echo 'export PYENV_ROOT=/var/lib/pyenv' >> /etc/skel/.bashrc
RUN echo 'export PATH=$PATH:$PYENV_ROOT/bin' >> /etc/skel/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> /etc/skel/.bashrc
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> /etc/skel/.bashrc
RUN echo 'export PYENV_ROOT=/var/lib/pyenv' >> /root/.bashrc
RUN echo 'export PATH=$PATH:$PYENV_ROOT/bin' >> /root/.bashrc
RUN echo 'eval "$(pyenv virtualenv-init -)"' >> /root/.bashrc
RUN echo 'eval "$(pyenv init -)"' >> /root/.bashrc
RUN . /root/.bash_profile; curl https://pyenv.run | bash 
RUN dnf -y install zlib-devel make bzip2-devel readline-devel sqlite-devel libffi-devel xz-devel
RUN . /root/.bash_profile; pyenv install 3.8.0 
RUN dnf -y erase zlib-devel make bzip2-devel readline-devel sqlite-devel  libffi-devel xz-devel
RUN . /root/.bash_profile; pyenv virtualenv 3.8.0 venv
RUN find /var/lib/pyenv -type d -exec chmod o+xw '{}' \;
COPY xfce /tmp/xfce 
RUN dnf -y install /tmp/xfce/*.rpm 
RUN rm -rf /tmp/xfce
RUN dnf clean all
RUN dnf autoremove

RUN dnf -y install openssl-devel 
RUN systemctl enable xrdp.service
RUN echo xfce4-session > /etc/skel/.Xclients
RUN chmod 755 /etc/skel/.Xclients
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo
RUN dnf check-update || :
RUN dnf -y install code
RUN code --install-extension ms-python.python --user-data-dir /tmp/.vscode
RUN code --install-extension eamodio.gitlens --user-data-dir /tmp/.vscode
RUN rm -rf /tmp/.vscode
RUN mv /root/.vscode /etc/skel/.vscode 
RUN groupadd sudoers
RUN echo '%sudoers ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers
EXPOSE 8000 3389
ADD https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/v1.5.4260/files/docker/systemctl3.py /usr/bin/systemctl
RUN chmod 755 /usr/bin/systemctl 
RUN dnf -y install openssh-server
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -P ''
RUN ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -P '' -t ecdsa 
RUN ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -P '' -t ed25519 
RUN rm /run/nologin
RUN systemctl enable "xrdp-sesman"
CMD [ "/usr/bin/systemctl"  ]
