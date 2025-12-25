# # Dockerfile for building and serving a Flutter web application

# # ---------- Build Stage ----------
# FROM cirrusci/flutter:stable AS build

# WORKDIR /app
# COPY . .

# RUN flutter pub get
# RUN flutter build web --release

# # ---------- Run Stage ----------
# FROM nginx:alpine

# COPY --from=build /app/build/web /usr/share/nginx/html

# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]
FROM nginx:alpine

COPY build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
