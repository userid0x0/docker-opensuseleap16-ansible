FROM docker.io/opensuse/leap:16.0

ENV pip_packages="ansible"

# Install systemd (instructions partly taken from CentOS)
RUN zypper -n install systemd && zypper clean \
    && find /lib/systemd/system/multi-user.target.wants ! \( -name '*getty*' -or -name '*logind*' -or -name '*systemd-user*' \) -type l \
    && rm -f /etc/systemd/system/*.wants/* \
    && rm -f /lib/systemd/system/local-fs.target.wants/* \
    && rm -f /lib/systemd/system/sockets.target.wants/*udev* \
    && rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
    && rm -f /lib/systemd/system/basic.target.wants/* \
    && rm -f /lib/systemd/system/anaconda.target.wants/*

# Install base requirements and Python
RUN zypper refresh \
    && zypper install -y \
      sudo \
      which \
      hostname \
      iproute2 \
      python313 \
      python313-pip \
      python313-wheel \
      python313-PyYAML \
    && zypper clean -a

# Upgrade pip, setuptools, and wheel.
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# Install Ansible via Pip (latest).
RUN pip3 install --no-cache-dir $pip_packages

# Disable requiretty in sudo.
#RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers

# Install a minimal Ansible inventory.
RUN mkdir -p /etc/ansible \
    && echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]