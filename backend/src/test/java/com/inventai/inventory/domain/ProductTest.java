package com.inventai.inventory.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.inventai.inventory.domain.exception.InvalidStockQuantityException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import com.inventai.inventory.domain.exception.InsufficientStockException;

import java.math.BigDecimal;

public class ProductTest {
    @Test
    void shoulIncreaseStockWhenQuantityIsPositive(){
        // given
        Product product = Product.withStock(new BigDecimal("10.000"));

        // When
        product.increaseStock(new BigDecimal("5.000"));

        // Then
        assertThat(product.getCurrentStock())
                .isEqualByComparingTo("15.000");
    }

    @Test
    void shouldRejectZeroQuantityWhenIncreaseStock(){
        // given
        Product product = Product.withStock(new BigDecimal("10.000"));

        // when/then
        assertThatThrownBy(() -> product.increaseStock(new BigDecimal("0")))
                .isInstanceOf(InvalidStockQuantityException.class);
    }

    @ParameterizedTest
    @ValueSource(strings = {"-1", "-10", "-100"})
    void shouldRejectNegativeQuantityWhenIncreaseStock(String quantity){
        // given
        Product product = Product.withStock(new BigDecimal("10.000"));

        // when / then
        assertThatThrownBy(() -> product.increaseStock(new BigDecimal(quantity)))
                .isInstanceOf(InvalidStockQuantityException.class);
    }

    @Test
    void shoulRejectNullQuantityWhenIncreaseStock(){
        Product product = Product.withStock(new BigDecimal("10.000"));
        assertThatThrownBy(() -> product.increaseStock(null))
                .isInstanceOf(InvalidStockQuantityException.class);
    }

    @Test
    void shouldDecreaseStockWhenQuantityIsAvailable() {

        // Given
        Product product = Product.withStock(new BigDecimal("10.000"));

        // When
        product.decreaseStock(new BigDecimal("3.000"));

        // Then
        assertThat(product.getCurrentStock())
                .isEqualByComparingTo("7.000");
    }

    @Test
    void shouldRejectDecreaseWhenStockIsInsufficient() {

        // Given
        Product product = Product.withStock(new BigDecimal("10.000"));

        // When / Then
        assertThatThrownBy(() ->
                product.decreaseStock(new BigDecimal("15.000"))
        ).isInstanceOf(InsufficientStockException.class);
    }

    @Test
    void shouldAllowDecreaseWhenQuantityMatchesAvailableStock() {

        // Given
        Product product = Product.withStock(new BigDecimal("10.000"));

        // When
        product.decreaseStock(new BigDecimal("10.000"));

        // Then
        assertThat(product.getCurrentStock())
                .isEqualByComparingTo("0.000");
    }

    @ParameterizedTest
    @ValueSource(strings = {"0", "-1", "-10.500"})
    void shouldRejectNonPositiveQuantityWhenDecreasingStock(String quantity) {

        // Given
        Product product = Product.withStock(new BigDecimal("10.000"));

        // When / Then
        assertThatThrownBy(() ->
                product.decreaseStock(new BigDecimal(quantity))
        ).isInstanceOf(InvalidStockQuantityException.class);
    }

    @Test
    void shouldRejectNullQuantityWhenDecreasingStock() {

        // Given
        Product product = Product.withStock(new BigDecimal("10.000"));

        // When / Then
        assertThatThrownBy(() ->
                product.decreaseStock(null)
        ).isInstanceOf(InvalidStockQuantityException.class);
    }

}
