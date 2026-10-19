package com.inventai.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.testcontainers.containers.PostgreSQLContainer;

/**
 * Provides reusable infrastructure for integration tests.
 *
 * <p>Integration tests use an isolated PostgreSQL instance and must never
 * depend on the developer's local database or credentials.</p>
 */
@TestConfiguration(proxyBeanMethods = false)
public class TestcontainersConfiguration {

    /**
     * Creates the PostgreSQL instance used by integration tests.
     *
     * @return isolated PostgreSQL container
     */
    @Bean
    @ServiceConnection
    PostgreSQLContainer<?> postgresContainer() {
        return new PostgreSQLContainer<>("postgres:17")
                .withDatabaseName("inventai_test")
                .withUsername("inventai_test")
                .withPassword("inventai_test");
    }
}