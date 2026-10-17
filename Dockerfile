FROM python:3.10-slim

WORKDIR /app

ENV XRAY_LOCATION_ASSET=/usr/local/bin/xray
ENV PATH="/usr/local/bin/xray:${PATH}"

# Install Nginx and Xray core
RUN apt-get update && apt-get install -y nginx wget unzip procps curl && \
    rm -rf /etc/nginx/sites-enabled/* /etc/nginx/conf.d/* && \
    mkdir -p /usr/local/bin/xray /run /var/log/nginx && \
    wget -q https://github.com/XTLS/Xray-core/releases/download/v1.8.11/Xray-linux-64.zip && \
    unzip -q Xray-linux-64.zip -d /usr/local/bin/xray && \
    chmod +x /usr/local/bin/xray/xray && \
    rm Xray-linux-64.zip && \
    apt-get clean

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Default: nginx listens on port 80 (needed for captive-portal bypass).
# For normal TLS deployment, set NGINX_PORT=443 at runtime.
ENV NGINX_PORT=80
EXPOSE 80 8080

CMD ["python", "app.py"]