FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openssh-server

RUN useradd -m -s /bin/bash ctfuser
RUN echo 'ctfuser:password123' | chpasswd

RUN mkdir -p /home/ctfuser/challenge
RUN echo "flag{linux_basics_are_fun}" > /home/ctfuser/.hidden_flag
RUN chmod 600 /home/ctfuser/.hidden_flag
RUN chown ctfuser:ctfuser /home/ctfuser/.hidden_flag

RUN mkdir -p /run/sshd
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

CMD ["/usr/sbin/sshd", "-D"]
