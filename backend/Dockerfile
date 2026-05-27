# ── Etapa 1: compilar el JAR ─────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copiamos primero el pom.xml para aprovechar la caché de capas de Docker:
# si el código cambia pero no las dependencias, Maven no las vuelve a bajar.
COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# ── Etapa 2: imagen final ligera (solo JRE, sin Maven ni código fuente) ───────
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
