plugins {
    java
    id("org.springframework.boot") version "3.3.2" apply false
    id("io.spring.dependency-management") version "1.1.6" apply false
}

subprojects {
    apply(plugin = "java-library")
    apply(plugin = "io.spring.dependency-management")

    group = "com.myserial"
    version = "0.0.1-SNAPSHOT"

    java {
        sourceCompatibility = JavaVersion.VERSION_17
    }

    repositories {
        mavenCentral()
    }

    the<io.spring.gradle.dependencymanagement.dsl.DependencyManagementExtension>().apply {
        imports {
            mavenBom("org.springframework.boot:spring-boot-dependencies:3.3.2")
            mavenBom("org.testcontainers:testcontainers-bom:1.19.8")
        }
    }

    configurations {
        compileOnly {
            extendsFrom(configurations.annotationProcessor.get())
        }
    }

    dependencies {
        compileOnly("org.projectlombok:lombok")
        annotationProcessor("org.projectlombok:lombok")
        testImplementation("org.springframework.boot:spring-boot-starter-test")
    }

    tasks.test {
        useJUnitPlatform()
    }
}
