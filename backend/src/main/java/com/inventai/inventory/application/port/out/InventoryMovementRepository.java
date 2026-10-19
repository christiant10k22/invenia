package com.inventai.inventory.application.port.out;

import com.inventai.inventory.domain.InventoryMovement;

/**
 * Defines persistence operations for inventory movement
 */
public interface InventoryMovementRepository {
    InventoryMovement save(InventoryMovement movement);
}
