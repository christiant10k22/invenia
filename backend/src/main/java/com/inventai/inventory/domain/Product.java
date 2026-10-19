package com.inventai.inventory.domain;

import com.inventai.inventory.domain.exception.InsufficientStockException;
import com.inventai.inventory.domain.exception.InvalidStockQuantityException;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;


public class Product {
    private BigDecimal currentStock;

    private Product(BigDecimal currentStock) {
        validateInitialStock(currentStock);
        this.currentStock = currentStock;
    }

    /**
     * Creates a product with an initial stock value
     *
     * @param currentStock initial available stock
     * @return product initialized with provided stock
     */
    public static Product withStock(BigDecimal currentStock) {
        return new Product(currentStock);
    }

    /**
     * Adds stock to the product
     *
     * @param quantity
     */
    public void increaseStock(BigDecimal quantity) {
        validatePositiveQuantity(quantity);

        this.currentStock = currentStock.add(quantity);
    }

    /**
     * Substract stock to the product
     *
     * @param quantity
     */
    public void decreaseStock(BigDecimal quantity) {
        validatePositiveQuantity(quantity);

        if (currentStock.compareTo(quantity) < 0) {
            throw new InsufficientStockException(
                    currentStock,
                    quantity
            );
        }

        currentStock = currentStock.subtract(quantity);
    }

    public BigDecimal getCurrentStock() {
        return currentStock;
    }

    private void validatePositiveQuantity(BigDecimal quantity) {

        if (quantity == null || quantity.compareTo(BigDecimal.ZERO) <= 0) {
            throw new InvalidStockQuantityException();
        }
    }

    private void validateInitialStock(BigDecimal quantity) {
        if (quantity == null || quantity.compareTo(BigDecimal.ZERO) < 0) {
            throw new InvalidStockQuantityException();
        }
    }

}
