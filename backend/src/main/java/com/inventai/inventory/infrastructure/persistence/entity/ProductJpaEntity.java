package com.inventai.inventory.infrastructure.persistence.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Represents the PostgreSQL persistence model for a product
 *
 * <p>This entity contains database mapping concerns.
 * Business rules belong to the domain model</p>
 */

@Entity
@Table(name = "product")
public class ProductJpaEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "inventory_id", nullable = false)
    private UUID inventoryId;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Column(
            name = "current_stock",
            nullable = false,
            precision = 14,
            scale = 3
    )
    private BigDecimal currentStock;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;

    /**
     * Required by JPA for entity instantiation.
     */
    protected ProductJpaEntity() {
    }

    /**
     * Creates the persistence representation of a product.
     *
     * @param inventoryId inventory owning the product
     * @param name product name
     * @param currentStock initial available stock
     */
    public ProductJpaEntity(
            UUID inventoryId,
            String name,
            BigDecimal currentStock) {

        this.inventoryId = inventoryId;
        this.name = name;
        this.currentStock = currentStock;
    }

    public UUID getId() {
        return id;
    }

    public UUID getInventoryId() {
        return inventoryId;
    }

    public String getName() {
        return name;
    }

    public BigDecimal getCurrentStock() {
        return currentStock;
    }

    public Long getVersion() {
        return version;
    }
}
