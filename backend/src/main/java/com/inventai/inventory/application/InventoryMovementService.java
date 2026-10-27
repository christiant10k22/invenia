package com.inventai.inventory.application;

import com.inventai.inventory.application.port.out.InventoryMovementRepository;
import com.inventai.inventory.application.port.out.ProductRepository;
import com.inventai.inventory.domain.InventoryMovement;
import com.inventai.inventory.domain.MovementType;
import com.inventai.inventory.domain.Product;

import java.math.BigDecimal;

public class InventoryMovementService {

    private final ProductRepository productRepository;
    private final InventoryMovementRepository movementRepository;

    /**
     * Creates the inventory movement application service.
     *
     * @param productRepository repository used to persist products
     * @param movementRepository repository used to persist movements
     */
    public InventoryMovementService(
            ProductRepository productRepository,
            InventoryMovementRepository movementRepository) {

        this.productRepository = productRepository;
        this.movementRepository = movementRepository;
    }

    /**
     * Registers incoming stock.
     *
     * @param product product receiving stock
     * @param quantity quantity to add
     * @return recorded movement
     */
    public InventoryMovement registerIncomingStock(
            Product product,
            BigDecimal quantity) {

        BigDecimal stockBefore = product.getCurrentStock();

        product.increaseStock(quantity);

        InventoryMovement movement = new InventoryMovement(
                MovementType.IN,
                quantity,
                stockBefore,
                product.getCurrentStock()
        );

        productRepository.save(product);
        movementRepository.save(movement);

        return movement;
    }

    /**
     * Registers outgoing stock.
     *
     * @param product product losing stock
     * @param quantity quantity to remove
     * @return recorded movement
     */
    public InventoryMovement registerOutgoingStock(
            Product product,
            BigDecimal quantity) {

        BigDecimal stockBefore = product.getCurrentStock();

        product.decreaseStock(quantity);

        InventoryMovement movement = new InventoryMovement(
                MovementType.OUT,
                quantity.negate(),
                stockBefore,
                product.getCurrentStock()
        );

        productRepository.save(product);
        movementRepository.save(movement);

        return movement;
    }
}
