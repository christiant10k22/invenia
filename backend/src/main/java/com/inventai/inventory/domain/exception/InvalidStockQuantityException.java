package com.inventai.inventory.domain.exception;

public class InvalidStockQuantityException extends RuntimeException{
    public InvalidStockQuantityException() {
        super("Stock quantity must be greater or equal to zero");
    }
}
