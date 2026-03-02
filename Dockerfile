FROM nginx:alpine

# 复制 index.html 到 nginx 的默认服务目录
COPY index.html /usr/share/nginx/html/

# 暴露 80 端口
EXPOSE 80

# 启动 nginx
CMD ["nginx", "-g", "daemon off;"]
