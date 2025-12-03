# Etapa 1 — Flutter 3.38.3 (Dart 3.8+)
FROM ghcr.io/cirruslabs/flutter:3.38.3 AS build

# Evitar warning de root
USER root

WORKDIR /app

COPY pubspec.yaml pubspec.lock* ./

RUN flutter pub get

COPY . .
RUN flutter clean
RUN flutter build web

# Etapa 2 — Nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
