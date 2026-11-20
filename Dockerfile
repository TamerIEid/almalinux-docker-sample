FROM almalinux:9@sha256:02df05719ef287ebd0df0a1eedb9172a00bd70703aed7b25660e426b8e0d6047

WORKDIR /opt/inventory
COPY inventory.py .
RUN command -v python3 && install -d -o 10001 -g 10001 /var/lib/inventory
USER 10001:10001
EXPOSE 8080
CMD ["python3", "-u", "/opt/inventory/inventory.py"]
