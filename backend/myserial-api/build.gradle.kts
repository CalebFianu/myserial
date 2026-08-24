plugins {
    id("org.springframework.boot")
}

dependencies {
    implementation(project(":myserial-domain"))
    implementation(project(":myserial-catalog"))
    implementation(project(":myserial-batch"))
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:2.5.0")
    implementation("com.auth0:java-jwt:4.4.0")
    testImplementation("org.testcontainers:postgresql")
    testImplementation("org.testcontainers:junit-jupiter")
    testImplementation("org.springframework.security:spring-security-test")
}
