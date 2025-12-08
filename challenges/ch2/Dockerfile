FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openssh-server

RUN useradd -m -s /bin/bash ctfuser
RUN echo 'ctfuser:password123' | chpasswd

RUN mkdir -p /home/ctfuser/challenge
RUN echo "flag{hidden_treasure}" > /home/ctfuser/challenge/.hidden_flag
RUN chmod 644 /home/ctfuser/challenge/.hidden_flag
RUN chown ctfuser:ctfuser /home/ctfuser/challenge/.hidden_flag

RUN mkdir -p /run/sshd
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

CMD ["/usr/sbin/sshd", "-D"]
