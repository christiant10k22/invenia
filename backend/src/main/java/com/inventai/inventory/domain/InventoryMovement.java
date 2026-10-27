package com.inventai.inventory.domain;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Represents an inmutable stock movement
 *
 * <p>A movement records how the stock changed and must never be
 * modified after creation. Corrections should create a compensanting
 * movement instead.</p>
 */
public class InventoryMovement {
    private final UUID id;
    private final UUID operationId;
    private final MovementType movementType;

    private final BigDecimal quantityChange;
    private final BigDecimal stockBefore;
    private final BigDecimal stockAfter;

    private final OffsetDateTime occurredAt;

    public InventoryMovement(
            MovementType movementType,
            BigDecimal quantityChange,
            BigDecimal stockBefore,
            BigDecimal stockAfter) {

        this.id = UUID.randomUUID();
        this.operationId = UUID.randomUUID();
        this.movementType = movementType;
        this.quantityChange = quantityChange;
        this.stockBefore = stockBefore;
        this.stockAfter = stockAfter;
        this.occurredAt = OffsetDateTime.now();
    }

    public UUID getId() {
        return id;
    }

    public UUID getOperationId() {
        return operationId;
    }

    public MovementType getMovementType() {
        return movementType;
    }

    public BigDecimal getQuantityChange() {
        return quantityChange;
    }

    public BigDecimal getStockBefore() {
        return stockBefore;
    }

    public BigDecimal getStockAfter() {
        return stockAfter;
    }

    public OffsetDateTime getOccurredAt() {
        return occurredAt;
    }
}
