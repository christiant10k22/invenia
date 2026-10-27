package com.inventai.inventory.application;

import com.inventai.inventory.application.port.out.InventoryMovementRepository;
import com.inventai.inventory.application.port.out.ProductRepository;
import com.inventai.inventory.domain.InventoryMovement;
import com.inventai.inventory.domain.MovementType;
import com.inventai.inventory.domain.Product;
import com.inventai.inventory.domain.exception.InsufficientStockException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.ArgumentMatchers.any;

/**
 * Unit test for inventory stock movement uses cases
 *
 * <p>These tests verify business orchestration without Spring,
 * PostgreSQL or external infrastructure</p>
 */
@ExtendWith(MockitoExtension.class)
class InventoryMovementServiceTest {

    @Mock
    private ProductRepository productRepository;

    @Mock
    private InventoryMovementRepository movementRepository;

    @InjectMocks
    private InventoryMovementService service;

    @Test
    void shouldRegisterIncomingStockMovement() {

        // Given
        Product product =
                Product.withStock(new BigDecimal("10.000"));

        // When
        InventoryMovement movement =
                service.registerIncomingStock(
                        product,
                        new BigDecimal("5.000")
                );

        // Then
        assertThat(product.getCurrentStock())
                .isEqualByComparingTo("15.000");

        assertThat(movement.getMovementType())
                .isEqualTo(MovementType.IN);

        assertThat(movement.getQuantityChange())
                .isEqualByComparingTo("5.000");

        assertThat(movement.getStockBefore())
                .isEqualByComparingTo("10.000");

        assertThat(movement.getStockAfter())
                .isEqualByComparingTo("15.000");

        verify(productRepository).save(product);
        verify(movementRepository).save(movement);
    }

    @Test
    void shouldRegisterOutgoingStockMovement() {

        // Given
        Product product =
                Product.withStock(new BigDecimal("10.000"));

        // When
        InventoryMovement movement =
                service.registerOutgoingStock(
                        product,
                        new BigDecimal("3.000")
                );

        // Then
        assertThat(product.getCurrentStock())
                .isEqualByComparingTo("7.000");

        assertThat(movement.getMovementType())
                .isEqualTo(MovementType.OUT);

        assertThat(movement.getQuantityChange())
                .isEqualByComparingTo("-3.000");

        assertThat(movement.getStockBefore())
                .isEqualByComparingTo("10.000");

        assertThat(movement.getStockAfter())
                .isEqualByComparingTo("7.000");

        verify(productRepository).save(product);
        verify(movementRepository).save(movement);
    }

    @Test
    void shouldNotPersistAnythingWhenStockIsInsufficient() {

        // Given
        Product product =
                Product.withStock(new BigDecimal("10.000"));

        // When / Then
        assertThatThrownBy(() ->
                service.registerOutgoingStock(
                        product,
                        new BigDecimal("15.000")
                )
        ).isInstanceOf(InsufficientStockException.class);

        assertThat(product.getCurrentStock())
                .isEqualByComparingTo("10.000");

        verify(productRepository, never()).save(product);
        verify(movementRepository, never()).save(
                any()
        );
    }
}