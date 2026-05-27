# ── Etapa 1: compilar Flutter web ────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Descargamos dependencias primero (capa cacheable)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copiamos el resto del código fuente
COPY . .

# API_URL se hornea en el binario en tiempo de compilación.
# Con /api como valor el navegador resuelve la URL contra el origen actual,
# y nginx hace el proxy hacia backend:8080 — sin hardcodear IPs.
ARG API_URL=/api
RUN flutter build web --dart-define=API_URL=$API_URL --release

# ── Etapa 2: servidor nginx ligero ────────────────────────────────────────────
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
