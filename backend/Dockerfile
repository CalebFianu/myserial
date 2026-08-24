# ── Build stage ────────────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jdk-alpine AS build
WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY settings.gradle.kts .
COPY build.gradle.kts .
COPY myserial-domain/build.gradle.kts myserial-domain/build.gradle.kts
COPY myserial-catalog/build.gradle.kts myserial-catalog/build.gradle.kts
COPY myserial-batch/build.gradle.kts myserial-batch/build.gradle.kts
COPY myserial-api/build.gradle.kts myserial-api/build.gradle.kts

RUN mkdir -p myserial-domain/src/main/java \
             myserial-catalog/src/main/java \
             myserial-batch/src/main/java \
             myserial-api/src/main/java \
    && chmod +x gradlew \
    && ./gradlew dependencies --no-daemon -q

COPY myserial-domain/src myserial-domain/src
COPY myserial-catalog/src myserial-catalog/src
COPY myserial-batch/src myserial-batch/src
COPY myserial-api/src myserial-api/src

RUN ./gradlew :myserial-api:bootJar --no-daemon -q

# ── Runtime stage ───────────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/myserial-api/build/libs/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
