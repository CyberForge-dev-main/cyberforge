FROM nginx:alpine

# Copy frontend files
COPY index.html /usr/share/nginx/html/
COPY config.js /usr/share/nginx/html/
COPY app.js /usr/share/nginx/html/

# Nginx будет настроен через nginx.conf в корне проекта
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
