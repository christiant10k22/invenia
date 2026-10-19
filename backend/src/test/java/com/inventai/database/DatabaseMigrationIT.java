package com.inventai.database;

import com.inventai.config.TestcontainersConfiguration;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Import(TestcontainersConfiguration.class)
public class DatabaseMigrationIT {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void shouldApplyInitialSchemaSuccessfully() {

        // Given
        List<String> tables = jdbcTemplate.queryForList(
                """
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = 'public'
                """,
                String.class
        );

        // Then
        assertThat(tables).contains(
                "app_user",
                "user_identity",
                "inventory",
                "inventory_section",
                "category",
                "inventory_location",
                "product",
                "inventory_movement",
                "audit_event",
                "application_error",
                "flyway_schema_history"
        );
    }
}
