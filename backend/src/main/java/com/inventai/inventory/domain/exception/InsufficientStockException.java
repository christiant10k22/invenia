package com.inventai.inventory.domain.exception;

import java.math.BigDecimal;

public class InsufficientStockException extends RuntimeException {
    public InsufficientStockException(BigDecimal availableStock, BigDecimal requestedQuantity) {
        super(
                "Insufficient stock. Available: "
                        + availableStock
                        + ", requested: "
                        + requestedQuantity
        );
    }
}
