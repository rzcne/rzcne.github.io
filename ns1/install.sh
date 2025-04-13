#!/bin/bash
set -e

# 自动生成随机密码
GEN_DB_PASS=$(openssl rand -hex 8)
GEN_ADMIN_PASS=$(openssl rand -hex 4)
GEN_SECRET_KEY=$(openssl rand -hex 16)

# 验证API密钥是否存在
if [ -z "$NS1_API_KEY" ]; then
  echo "错误：必须通过环境变量提供NS1_API_KEY"
  echo "示例：sudo NS1_API_KEY=your_key bash install.sh"
  exit 1
fi

# 安装依赖
apt-get update
apt-get install -y python3 python3-pip git nginx mysql-server

# 配置MySQL
mysql -e "CREATE DATABASE ns1_admin;"
mysql -e "CREATE USER 'ns1_admin'@'localhost' IDENTIFIED BY '${GEN_DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ns1_admin.* TO 'ns1_admin'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# 克隆代码
git clone https://github.com/example/ns1-admin.git /opt/ns1-admin
cd /opt/ns1-admin

# 创建环境文件
cat > .env <<EOF
NS1_API_KEY='${NS1_API_KEY}'
SECRET_KEY='${GEN_SECRET_KEY}'
DB_URI=mysql+pymysql://ns1_admin:${GEN_DB_PASS}@localhost/ns1_admin
ADMIN_USER=admin
ADMIN_PASS=${GEN_ADMIN_PASS}
EOF

# 安装依赖
pip3 install -r requirements.txt

# 初始化数据库
flask db upgrade

# 创建管理员账户
mysql ns1_admin -e "INSERT INTO user (username, password_hash) VALUES ('admin', '$(python3 -c "from werkzeug.security import generate_password_hash; print(generate_password_hash('${GEN_ADMIN_PASS}'))")');"

# 配置Nginx
cat > /etc/nginx/sites-available/ns1-admin <<EOF
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    
    location /static {
        alias /opt/ns1-admin/static;
    }
}
EOF

ln -s /etc/nginx/sites-available/ns1-admin /etc/nginx/sites-enabled/
systemctl restart nginx

# 配置系统服务
cat > /etc/systemd/system/ns1-admin.service <<EOF
[Unit]
Description=NS1 Admin Web Interface
After=network.target mysql.service

[Service]
User=root
WorkingDirectory=/opt/ns1-admin
EnvironmentFile=/opt/ns1-admin/.env
ExecStart=/usr/bin/gunicorn --workers 3 --bind 127.0.0.1:5000 app:app

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start ns1-admin
systemctl enable ns1-admin

# 显示安装信息
PUBLIC_IP=$(curl -s ifconfig.me)
echo "安装完成！"
echo "访问地址：http://${PUBLIC_IP}/login"
echo "管理员账号：admin"
echo "初始密码：${GEN_ADMIN_PASS}"
echo "请及时修改初始密码！"
