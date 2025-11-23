FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openssh-server

RUN useradd -m -s /bin/bash ctfuser
RUN echo 'ctfuser:password123' | chpasswd

RUN mkdir -p /home/ctfuser/secret_dir
RUN echo "flag{find_and_conquer}" > /home/ctfuser/secret_dir/flag3.txt
RUN chmod 644 /home/ctfuser/secret_dir/flag3.txt
RUN chown ctfuser:ctfuser /home/ctfuser/secret_dir/flag3.txt

RUN mkdir -p /run/sshd
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

CMD ["/usr/sbin/sshd", "-D"]
