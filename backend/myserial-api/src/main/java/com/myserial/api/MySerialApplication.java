package com.myserial.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableCaching
@EnableScheduling
@ComponentScan(basePackages = {"com.myserial"})
@EntityScan(basePackages = {"com.myserial.domain.entity"})
@EnableJpaRepositories(basePackages = {"com.myserial.domain.repository"})
public class MySerialApplication {

    public static void main(String[] args) {
        SpringApplication.run(MySerialApplication.class, args);
    }
}
