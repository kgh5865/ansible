FROM rockylinux:8

# 필요한 패키지 다운 및 캐시 정리
RUN dnf update -y && \
    dnf -y install sudo python36 openssh-server && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# pam_nologin(일반 사용자의 로그인을 일시적으로 비활성화) 오류 제거
RUN rm -f /run/nologin

# SSH 서버의 호스트 키 자동 생성
RUN ssh-keygen -A

# ansible 사용자 생성 & 비번 없이 sudo 권한 설정
RUN adduser ansible && \
    mkdir -p /etc/sudoers.d && \
    echo "ansible ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ansible && \
    chmod 0440 /etc/sudoers.d/ansible

# .ssh 권한 설정
RUN mkdir -p /home/ansible/.ssh && \
    chmod 700 /home/ansible/.ssh && \
    chown ansible:ansible /home/ansible/.ssh

# awx-rocky.pub 파일 가져오기
COPY awx-rocky.pub /home/ansible/.ssh/authorized_keys

# public key 파일 권한, 소유권 설정
RUN chmod 600 /home/ansible/.ssh/authorized_keys && \
    chown ansible:ansible /home/ansible/.ssh/authorized_keys

# ansible 사용자로 변경
USER ansible

# SSH port
EXPOSE 22

# SSH 서비스 시작
CMD ["/usr/sbin/sshd", "-D"]