# Release Notes

## Docker Image Builds

此版本包含预编译的 Docker 镜像，支持多个架构，可直接下载使用。

### 可下载的镜像文件

| 文件名 | 平台 | 说明 |
|--------|------|------|
| `my-nginx-linux-amd64.tar.gz` | x86_64 | Intel/AMD 64位处理器 |
| `my-nginx-linux-arm64.tar.gz` | ARM64 | ARM 64位（树莓派4、AWS Graviton等） |
| `my-nginx-linux-arm-v7.tar.gz` | ARM32 | ARM 32位（树莓派3等） |

### 快速开始

#### 方式一：使用下载的 tar 包

1. 从本 Release 页面下载对应平台的镜像文件，例如 `my-nginx-linux-amd64.tar.gz`

2. 解压并加载镜像：
   ```bash
   gunzip my-nginx-linux-amd64.tar.gz
   docker load -i my-nginx-linux-amd64.tar
   ```

3. 查看加载的镜像：
   ```bash
   docker images
   ```

4. 运行容器：
   ```bash
   docker run -p 80:80 <image-id>
   ```
   
   或使用 docker-compose：
   ```bash
   docker run --name my-nginx -p 80:80 -d <image-id>
   docker exec my-nginx cat /usr/share/nginx/html/index.html
   ```

#### 方式二：从 Docker Hub 拉取

预编译的多平台镜像也发布到 Docker Hub：

```bash
docker pull $DOCKER_USERNAME/my-nginx:latest
docker run -p 80:80 $DOCKER_USERNAME/my-nginx:latest
```

### 系统要求

- **x86_64 (amd64)**：任何现代 Linux、macOS、Windows 系统
- **ARM64**：树莓派 4、AWS Graviton、Apple Silicon with Docker Desktop 等
- **ARM v7**：树莓派 3、Odroid 等 32 位 ARM 设备

### 验证镜像

加载镜像后，可以验证其内容：

```bash
# 声查看镜像信息
docker inspect <image-id>

# 运行镜像并查看 Nginx 版本
docker run --rm <image-id> nginx -v
```

### 更多信息

- Dockerfile 使用 `nginx:alpine` 作为基础镜像，体积小，安全性好
- 默认暴露端口：80
- 自动包含 index.html 文件
