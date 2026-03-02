# アセンブリ開発環境用のDockerfile
FROM ubuntu:22.04

# タイムゾーンの設定（対話的な入力を避ける）
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    nasm \
    gcc \
    gdb \
    make \
    vim \
    nano \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの設定
WORKDIR /app

# デフォルトコマンド
CMD ["/bin/bash"]
