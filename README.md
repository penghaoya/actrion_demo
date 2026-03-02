# GitHub Actions nginx 镜像构建项目

此项目使用 Docker 和 GitHub Actions 自动构建 nginx 镜像。

## 项目结构

```
.
├── Dockerfile           # Docker 镜像定义
├── index.html          # 静态网站文件
├── .github
│   └── workflows
│       └── build.yml   # GitHub Actions 自动构建工作流
└── README.md           # 本文件
```

## 前置条件

1. GitHub 账号和仓库
2. Docker Hub 账号（用于推送镜像）

## 配置步骤

### 1. 设置 GitHub Secrets

在你的 GitHub 仓库中，进入 **Settings > Secrets and variables > Actions**，添加以下 secrets：

- `DOCKER_USERNAME`: 你的 Docker Hub 用户名
- `DOCKER_PASSWORD`: 你的 Docker Hub 密码或 Personal Access Token

### 2. 推送代码到 GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your-username/your-repo.git
git push -u origin main
```

### 3. 自动构建

#### 推送到主分支
每当你推送代码到 `main` 或 `master` 分支时，GitHub Actions 会自动：
- 拉取最新代码
- **并发构建** x86_64、ARM64、ARM v7 三个平台的镜像
- 推送多平台镜像到 Docker Hub

#### 发布版本到 Releases
创建新标签发布版本：

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 会自动：
- 构建所有平台的镜像
- 将镜像二进制文件（tar 格式）上传到 GitHub Releases
- 创建可下载的 Release 版本

### 4. 下载预构建镜像

访问你的 GitHub Releases 页面，下载对应平台的镜像文件：

```bash
# 例如下载 x86_64 版本
# 从 Releases 页面下载 my-nginx-linux-amd64.tar.gz

# 解压镜像
gunzip my-nginx-linux-amd64.tar.gz

# 加载镜像到本地 Docker
docker load -i my-nginx-linux-amd64.tar

# 查看已加载的镜像
docker images

# 运行容器
docker run -p 80:80 <image-id>
```

### 每个平台的镜像文件

| 文件名 | 平台 | 用途 |
|--------|------|------|
| `my-nginx-linux-amd64.tar.gz` | x86_64 | Intel/AMD 服务器和桌面 |
| `my-nginx-linux-arm64.tar.gz` | ARM64 | 树莓派 4、AWS Graviton、Apple Silicon 等 |
| `my-nginx-linux-arm-v7.tar.gz` | ARM v7 | 树莓派 3、Orange Pi 等 |

## 本地测试

### 构建镜像

```bash
docker build -t my-nginx:latest .
```

### 运行容器

```bash
docker run -p 80:80 my-nginx:latest
```

访问 `http://localhost` 即可查看网站。

## 镜像说明

- **Base Image**: `nginx:alpine` (轻量级 Nginx 镜像)
- **支持平台**:
  - linux/amd64 (Intel/AMD 64-bit)
  - linux/arm64 (ARM 64-bit)
  - linux/arm/v7 (ARM 32-bit)
- **端口**: 80
- **文件**: index.html 文件会复制到 `/usr/share/nginx/html/` 目录

## GitHub Actions 工作流说明

工作流文件 `.github/workflows/build.yml` 包含三个任务：

### 1. build
- **触发条件**: 任何时候 push 或 PR
- **功能**: 并发构建三个平台的镜像（amd64、arm64、arm/v7）
- **处理流程**:
  1. 使用 QEMU 支持跨平台构建
  2. 构建 Docker 镜像并导出为 tar 文件
  3. 使用 gzip 压缩 tar 文件
  4. 将压缩文件上传为 GitHub Actions 制品
- **输出文件**: 
  - `my-nginx-linux-amd64.tar.gz`
  - `my-nginx-linux-arm64.tar.gz`
  - `my-nginx-linux-arm-v7.tar.gz`

### 2. publish-multiarch
- **触发条件**: push 到 main/master 或创建标签
- **功能**: 构建多平台镜像并推送到 Docker Hub
- **标签**: 
  - `latest` (对应 main/master)
  - `<version>` (对应版本标签)

### 3. release
- **触发条件**: 创建版本标签（如 v1.0.0）
- **功能**: 从 build 任务的制品中下载所有平台的镜像，创建 GitHub Release
- **产物**: Release 页面上可直接下载的压缩镜像文件

## 可选配置

如果你想推送到 GitHub Container Registry (GHCR) 而不是 Docker Hub，可以修改工作流文件：

```yaml
- name: Login to GHCR
  uses: docker/login-action@v2
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

- name: Build and push
  uses: docker/build-push-action@v4
  with:
    context: .
    push: true
    tags: ghcr.io/${{ github.repository }}:latest
    platforms: linux/amd64,linux/arm64,linux/arm/v7
```

## 常见问题

### Q: 为什么选择这三个平台？
A: 
- **linux/amd64**: 最常见的服务器/桌面平台（Intel/AMD）
- **linux/arm64**: 树莓派 4、AWS Graviton、Apple Silicon（Docker Desktop）等
- **linux/arm/v7**: 树莓派 3、旧的 ARM 设备等

### Q: 如何在本地测试其他平台的镜像？
A: 使用 QEMU 模拟器：
```bash
docker buildx build --platform linux/arm64 -t my-nginx:arm64 .
```

### Q: Release 中的 tar.gz 文件如何使用？
A:
```bash
# 1. 下载 my-nginx-linux-amd64.tar.gz（或对应平台的版本）

# 2. 解压文件
gunzip my-nginx-linux-amd64.tar.gz

# 3. 加载镜像
docker load -i my-nginx-linux-amd64.tar

# 4. 查看镜像ID
docker images

# 5. 运行容器
docker run -p 80:80 <image-id>
# 或指定镜像名称运行
docker run -p 80:80 my-nginx:latest
```

