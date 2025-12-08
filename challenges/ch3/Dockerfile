FROM ubuntu:22.04

RUN apt-get update && apt-get install -y openssh-server

RUN useradd -m -s /bin/bash ctfuser
RUN echo 'ctfuser:password123' | chpasswd

# Создаём challenge директорию и файл с флагом
RUN mkdir -p /home/ctfuser/challenge
RUN echo "flag{env_secrets}" > /home/ctfuser/challenge/flag.txt
RUN chmod 644 /home/ctfuser/challenge/flag.txt
RUN chown ctfuser:ctfuser /home/ctfuser/challenge/flag.txt

# ENV флаг (для бонуса)
ENV SECRET_FLAG="flag{env_secrets}"

RUN mkdir -p /run/sshd
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

CMD ["/usr/sbin/sshd", "-D"]
