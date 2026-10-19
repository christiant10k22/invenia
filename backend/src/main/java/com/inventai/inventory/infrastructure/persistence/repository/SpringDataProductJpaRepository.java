package com.inventai.inventory.infrastructure.persistence.repository;

import com.inventai.inventory.infrastructure.persistence.entity.ProductJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

/**
 * Provides JPA persistence operations for product entities.
 *
 * <p>Used by persistence adapters, not directly by
 * inventory domain services.</p>
 */
public interface SpringDataProductJpaRepository
        extends JpaRepository<ProductJpaEntity, UUID> {
}