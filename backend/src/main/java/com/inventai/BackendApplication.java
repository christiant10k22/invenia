package com.inventai;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class BackendApplication {
    public static void main(String[] args) {

        String dbUser = System.getenv("POSTGRES_USER");
        String dbPassword = System.getenv("POSTGRES_PASSWORD");
        String dbName = System.getenv("POSTGRES_DB");

        System.out.println("POSTGRES_DB recibido: " + dbName);
        System.out.println("POSTGRES_USER recibido: " + dbUser);
        System.out.println("POSTGRES_PASSWORD recibido: " + dbPassword);
        System.out.println("POSTGRES_PASSWORD existe: " + (dbPassword != null));
        System.out.println(
                "POSTGRES_PASSWORD longitud: "
                        + (dbPassword != null ? dbPassword.length() : 0)
        );

        SpringApplication.run(BackendApplication.class, args);
    }

}
