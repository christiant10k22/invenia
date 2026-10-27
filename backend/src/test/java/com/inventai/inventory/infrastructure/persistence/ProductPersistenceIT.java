package com.inventai.inventory.infrastructure.persistence;

import com.inventai.config.TestcontainersConfiguration;
import com.inventai.inventory.infrastructure.persistence.entity.ProductJpaEntity;
import com.inventai.inventory.infrastructure.persistence.repository.SpringDataProductJpaRepository;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Verifies product persistence against a real PostgreSQL database.
 *
 * <p>Tests execute with Testcontainers and must not depend
 * on the development database or local credentials.</p>
 */
@SpringBootTest
@Import(TestcontainersConfiguration.class)
@Transactional
class ProductPersistenceIT {

    @Autowired
    private SpringDataProductJpaRepository repository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private EntityManager entityManager;

    @Test
    void shouldPersistAndRetrieveProduct() {

        // Given
        UUID userId = UUID.randomUUID();
        UUID inventoryId = UUID.randomUUID();

        jdbcTemplate.update(
                """
                INSERT INTO app_user (id, email)
                VALUES (?, ?)
                """,
                userId,
                "test-" + userId + "@example.test"
        );

        jdbcTemplate.update(
                """
                INSERT INTO inventory (id, owner_user_id, name)
                VALUES (?, ?, ?)
                """,
                inventoryId,
                userId,
                "Test Inventory"
        );

        ProductJpaEntity product = new ProductJpaEntity(
                inventoryId,
                "Coca-Cola 600ml",
                new BigDecimal("10.000")
        );

        // When
        ProductJpaEntity saved = repository.saveAndFlush(product);

        UUID productId = saved.getId();

        entityManager.clear();

        // Then
        assertThat(productId).isNotNull();

        ProductJpaEntity retrieved = repository.findById(productId)
                .orElseThrow();

        assertThat(retrieved.getName())
                .isEqualTo("Coca-Cola 600ml");

        assertThat(retrieved.getInventoryId())
                .isEqualTo(inventoryId);

        assertThat(retrieved.getCurrentStock())
                .isEqualByComparingTo("10.000");
    }
}