package com.inventai.inventory.application.port.out;

import com.inventai.inventory.domain.Product;

/**
 * Defines persistence operations required by the inventory application
 * for products.
 *
 * <p>The application layer depends on this abstraction instead of a
 * specific persistence technology.</p>
 */
public interface ProductRepository {
    Product save(Product product);
}
