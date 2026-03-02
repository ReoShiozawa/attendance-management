FROM nginx:alpine

# デフォルト設定を削除
RUN rm /etc/nginx/conf.d/default.conf

# カスタム設定をコピー
COPY nginx.conf /etc/nginx/conf.d/

# 静的ファイルをコピー
COPY index.html /usr/share/nginx/html/
COPY login.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/
COPY login.js /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
