-- =========================================================
-- InventAI
-- V1 - Initial Schema
-- =========================================================


-- =========================================================
-- COMMON FUNCTIONS
-- =========================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION prevent_immutable_mutation()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION
        'Records in table % are immutable. Create a compensating record instead.',
        TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;


-- =========================================================
-- USERS
-- =========================================================

CREATE TABLE app_user (
                          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                          email VARCHAR(255) NOT NULL,

    -- Puede ser NULL si utiliza Google / Apple
                          password_hash VARCHAR(255),

                          first_name VARCHAR(100),
                          last_name VARCHAR(100),
                          display_name VARCHAR(150),

                          phone VARCHAR(30),
                          avatar_url VARCHAR(500),

                          locale VARCHAR(10) NOT NULL DEFAULT 'es-MX',
                          timezone VARCHAR(60) NOT NULL DEFAULT 'America/Mexico_City',

                          email_verified_at TIMESTAMPTZ,

                          onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,

                          last_login_at TIMESTAMPTZ,

                          active BOOLEAN NOT NULL DEFAULT TRUE,

    -- Se utilizará posteriormente con @Version de JPA
                          version BIGINT NOT NULL DEFAULT 0,

                          created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Eliminación lógica
                          deleted_at TIMESTAMPTZ
);


CREATE UNIQUE INDEX uk_app_user_email
    ON app_user (LOWER(email))
    WHERE deleted_at IS NULL;


CREATE TRIGGER trg_app_user_updated_at
    BEFORE UPDATE ON app_user
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();


-- =========================================================
-- USER IDENTITIES
-- Google / Apple / local / futuros proveedores
-- =========================================================

CREATE TABLE user_identity (
                               id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                               user_id UUID NOT NULL,

                               provider VARCHAR(30) NOT NULL,

                               provider_user_id VARCHAR(255) NOT NULL,

                               provider_email VARCHAR(255),

                               active BOOLEAN NOT NULL DEFAULT TRUE,

                               created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                               last_used_at TIMESTAMPTZ,

                               CONSTRAINT fk_user_identity_user
                                   FOREIGN KEY (user_id)
                                       REFERENCES app_user(id),

                               CONSTRAINT uk_user_identity_provider
                                   UNIQUE (provider, provider_user_id)
);


CREATE INDEX idx_user_identity_user
    ON user_identity(user_id);


-- =========================================================
-- INVENTORIES
-- =========================================================

CREATE TABLE inventory (
                           id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                           owner_user_id UUID NOT NULL,

                           name VARCHAR(150) NOT NULL,
                           description VARCHAR(500),

    -- HOME, BUSINESS, COLLECTION, TOOLS, etc.
                           inventory_type VARCHAR(50),

                           currency_code VARCHAR(3) NOT NULL DEFAULT 'MXN',

    -- Configuración flexible del inventario
                           settings JSONB NOT NULL DEFAULT '{}'::jsonb,

                           active BOOLEAN NOT NULL DEFAULT TRUE,

                           version BIGINT NOT NULL DEFAULT 0,

                           created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                           deleted_at TIMESTAMPTZ,

                           CONSTRAINT fk_inventory_owner
                               FOREIGN KEY (owner_user_id)
                                   REFERENCES app_user(id)
);


CREATE INDEX idx_inventory_owner
    ON inventory(owner_user_id);


CREATE TRIGGER trg_inventory_updated_at
    BEFORE UPDATE ON inventory
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();


-- =========================================================
-- SECTIONS / APARTADOS
-- =========================================================

CREATE TABLE inventory_section (
                                   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                                   inventory_id UUID NOT NULL,

    -- Permite futuros subapartados
                                   parent_section_id UUID,

                                   name VARCHAR(150) NOT NULL,
                                   description VARCHAR(500),

                                   sort_order INTEGER NOT NULL DEFAULT 0,

                                   active BOOLEAN NOT NULL DEFAULT TRUE,

                                   version BIGINT NOT NULL DEFAULT 0,

                                   created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                   updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                   deleted_at TIMESTAMPTZ,

                                   CONSTRAINT fk_section_inventory
                                       FOREIGN KEY (inventory_id)
                                           REFERENCES inventory(id),

    -- Necesario para garantizar que padre/hijo pertenezcan
    -- al mismo inventario
                                   CONSTRAINT uk_section_id_inventory
                                       UNIQUE (id, inventory_id),

                                   CONSTRAINT fk_section_parent
                                       FOREIGN KEY (parent_section_id, inventory_id)
                                           REFERENCES inventory_section(id, inventory_id)
);


CREATE INDEX idx_section_inventory
    ON inventory_section(inventory_id);


CREATE INDEX idx_section_parent
    ON inventory_section(parent_section_id);


CREATE UNIQUE INDEX uk_section_name_parent
    ON inventory_section (
                          inventory_id,
                          COALESCE(
            parent_section_id,
            '00000000-0000-0000-0000-000000000000'::uuid
        ),
                          LOWER(name)
        )
    WHERE deleted_at IS NULL;


CREATE TRIGGER trg_section_updated_at
    BEFORE UPDATE ON inventory_section
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();


-- =========================================================
-- CATEGORIES
-- =========================================================

CREATE TABLE category (
                          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                          inventory_id UUID NOT NULL,

                          name VARCHAR(120) NOT NULL,
                          description VARCHAR(500),

                          active BOOLEAN NOT NULL DEFAULT TRUE,

                          version BIGINT NOT NULL DEFAULT 0,

                          created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                          deleted_at TIMESTAMPTZ,

                          CONSTRAINT fk_category_inventory
                              FOREIGN KEY (inventory_id)
                                  REFERENCES inventory(id),

                          CONSTRAINT uk_category_id_inventory
                              UNIQUE (id, inventory_id)
);


CREATE INDEX idx_category_inventory
    ON category(inventory_id);


CREATE UNIQUE INDEX uk_category_name_inventory
    ON category(inventory_id, LOWER(name))
    WHERE deleted_at IS NULL;


CREATE TRIGGER trg_category_updated_at
    BEFORE UPDATE ON category
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();


-- =========================================================
-- LOCATIONS
-- =========================================================

CREATE TABLE inventory_location (
                                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                                    inventory_id UUID NOT NULL,

                                    name VARCHAR(150) NOT NULL,
                                    description VARCHAR(500),

                                    active BOOLEAN NOT NULL DEFAULT TRUE,

                                    version BIGINT NOT NULL DEFAULT 0,

                                    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                    deleted_at TIMESTAMPTZ,

                                    CONSTRAINT fk_location_inventory
                                        FOREIGN KEY (inventory_id)
                                            REFERENCES inventory(id),

                                    CONSTRAINT uk_location_id_inventory
                                        UNIQUE (id, inventory_id)
);


CREATE INDEX idx_location_inventory
    ON inventory_location(inventory_id);


CREATE UNIQUE INDEX uk_location_name_inventory
    ON inventory_location(inventory_id, LOWER(name))
    WHERE deleted_at IS NULL;


CREATE TRIGGER trg_location_updated_at
    BEFORE UPDATE ON inventory_location
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();


-- =========================================================
-- PRODUCTS
-- =========================================================

CREATE TABLE product (
                         id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                         inventory_id UUID NOT NULL,

                         section_id UUID,
                         category_id UUID,
                         location_id UUID,

                         name VARCHAR(200) NOT NULL,
                         description TEXT,

                         sku VARCHAR(100),
                         barcode VARCHAR(150),

    -- PIECE, KG, LITER, BOX, PACKAGE...
                         unit VARCHAR(50) NOT NULL DEFAULT 'PIECE',

                         current_stock NUMERIC(14,3) NOT NULL DEFAULT 0,
                         minimum_stock NUMERIC(14,3) NOT NULL DEFAULT 0,

                         cost NUMERIC(14,2),
                         sale_price NUMERIC(14,2),

    -- Información opcional para exportación /
    -- sistemas externos de facturación
                         sat_product_key VARCHAR(20),
                         sat_unit_key VARCHAR(10),

    -- Ej. IVA 16% = 0.16
                         tax_rate NUMERIC(6,4),

                         tax_included BOOLEAN NOT NULL DEFAULT FALSE,

    -- Campos personalizados definidos por el usuario
                         custom_attributes JSONB NOT NULL DEFAULT '{}'::jsonb,

                         active BOOLEAN NOT NULL DEFAULT TRUE,

                         version BIGINT NOT NULL DEFAULT 0,

                         created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                         deleted_at TIMESTAMPTZ,

                         CONSTRAINT fk_product_inventory
                             FOREIGN KEY (inventory_id)
                                 REFERENCES inventory(id),

                         CONSTRAINT fk_product_section
                             FOREIGN KEY (section_id, inventory_id)
                                 REFERENCES inventory_section(id, inventory_id),

                         CONSTRAINT fk_product_category
                             FOREIGN KEY (category_id, inventory_id)
                                 REFERENCES category(id, inventory_id),

                         CONSTRAINT fk_product_location
                             FOREIGN KEY (location_id, inventory_id)
                                 REFERENCES inventory_location(id, inventory_id),

                         CONSTRAINT uk_product_id_inventory
                             UNIQUE (id, inventory_id),

                         CONSTRAINT chk_product_stock
                             CHECK (current_stock >= 0),

                         CONSTRAINT chk_product_minimum_stock
                             CHECK (minimum_stock >= 0),

                         CONSTRAINT chk_product_cost
                             CHECK (cost IS NULL OR cost >= 0),

                         CONSTRAINT chk_product_sale_price
                             CHECK (sale_price IS NULL OR sale_price >= 0),

                         CONSTRAINT chk_product_tax_rate
                             CHECK (
                                 tax_rate IS NULL
                                     OR (tax_rate >= 0 AND tax_rate <= 1)
                                 )
);


CREATE INDEX idx_product_inventory
    ON product(inventory_id);


CREATE INDEX idx_product_section
    ON product(section_id);


CREATE INDEX idx_product_category
    ON product(category_id);


CREATE INDEX idx_product_location
    ON product(location_id);


CREATE INDEX idx_product_name
    ON product(name);


CREATE INDEX idx_product_custom_attributes
    ON product USING GIN(custom_attributes);


CREATE UNIQUE INDEX uk_product_inventory_sku
    ON product(inventory_id, sku)
    WHERE sku IS NOT NULL
      AND deleted_at IS NULL;


CREATE UNIQUE INDEX uk_product_inventory_barcode
    ON product(inventory_id, barcode)
    WHERE barcode IS NOT NULL
      AND deleted_at IS NULL;


CREATE TRIGGER trg_product_updated_at
    BEFORE UPDATE ON product
    FOR EACH ROW
    EXECUTE FUNCTION set_updated_at();


-- =========================================================
-- INVENTORY MOVEMENTS
-- Ledger / historial inmutable
-- =========================================================

CREATE TABLE inventory_movement (
                                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Agrupa varios movimientos de una misma operación
    -- Ej. una venta con cinco productos
                                    operation_id UUID NOT NULL DEFAULT gen_random_uuid(),

                                    inventory_id UUID NOT NULL,
                                    product_id UUID NOT NULL,

                                    created_by_user_id UUID,

    -- IN, OUT, SALE, PURCHASE, ADJUSTMENT,
    -- REVERSAL, IMPORT, etc.
                                    movement_type VARCHAR(30) NOT NULL,

    -- Positivo para entrada
    -- Negativo para salida
                                    quantity_change NUMERIC(14,3) NOT NULL,

                                    stock_before NUMERIC(14,3) NOT NULL,
                                    stock_after NUMERIC(14,3) NOT NULL,

    -- WEB, MOBILE, AI, IMPORT, SYSTEM...
                                    source VARCHAR(30) NOT NULL DEFAULT 'SYSTEM',

    -- Permite relacionarlo después con:
    -- SALE, PURCHASE, IMPORT, etc.
                                    reference_type VARCHAR(50),
                                    reference_id UUID,

    -- Si corrige/revierte otro movimiento
                                    reversal_of_movement_id UUID,

                                    reason VARCHAR(150),
                                    notes VARCHAR(500),

    -- Identificador para seguir una petición completa
                                    correlation_id UUID,

                                    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

    -- Momento real de la operación
                                    occurred_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Momento en que se registró
                                    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                    CONSTRAINT fk_movement_product
                                        FOREIGN KEY (product_id, inventory_id)
                                            REFERENCES product(id, inventory_id),

                                    CONSTRAINT fk_movement_user
                                        FOREIGN KEY (created_by_user_id)
                                            REFERENCES app_user(id),

                                    CONSTRAINT fk_movement_reversal
                                        FOREIGN KEY (reversal_of_movement_id)
                                            REFERENCES inventory_movement(id),

                                    CONSTRAINT chk_movement_quantity
                                        CHECK (quantity_change <> 0),

                                    CONSTRAINT chk_movement_stock_before
                                        CHECK (stock_before >= 0),

                                    CONSTRAINT chk_movement_stock_after
                                        CHECK (stock_after >= 0),

    -- Garantiza matemáticamente la consistencia
                                    CONSTRAINT chk_movement_balance
                                        CHECK (
                                            stock_after =
                                            stock_before + quantity_change
                                            )
);


CREATE INDEX idx_movement_inventory_time
    ON inventory_movement(inventory_id, occurred_at);


CREATE INDEX idx_movement_product_time
    ON inventory_movement(product_id, occurred_at);


CREATE INDEX idx_movement_operation
    ON inventory_movement(operation_id);


CREATE INDEX idx_movement_correlation
    ON inventory_movement(correlation_id);


CREATE INDEX idx_movement_reference
    ON inventory_movement(reference_type, reference_id);


CREATE UNIQUE INDEX uk_movement_reversal
    ON inventory_movement(reversal_of_movement_id)
    WHERE reversal_of_movement_id IS NOT NULL;


-- Un movimiento registrado no puede editarse ni borrarse.
CREATE TRIGGER trg_inventory_movement_immutable
    BEFORE UPDATE OR DELETE ON inventory_movement
FOR EACH ROW
EXECUTE FUNCTION prevent_immutable_mutation();


-- =========================================================
-- AUDIT EVENTS
-- Auditoría funcional
-- =========================================================

CREATE TABLE audit_event (
                             id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                             inventory_id UUID,
                             user_id UUID,

    -- CREATE, UPDATE, DELETE, LOGIN,
    -- IMPORT, SALE, AI_CONFIRMATION...
                             action VARCHAR(50) NOT NULL,

                             entity_type VARCHAR(80) NOT NULL,
                             entity_id UUID,

    -- MOBILE, API, AI, IMPORT, SYSTEM...
                             source VARCHAR(30) NOT NULL DEFAULT 'SYSTEM',

                             operation_id UUID,
                             correlation_id UUID,

    -- Nunca almacenar contraseñas, tokens
    -- u otra información sensible aquí.
                             before_data JSONB,
                             after_data JSONB,

                             metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

                             ip_address INET,
                             user_agent VARCHAR(500),

                             created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                             CONSTRAINT fk_audit_inventory
                                 FOREIGN KEY (inventory_id)
                                     REFERENCES inventory(id),

                             CONSTRAINT fk_audit_user
                                 FOREIGN KEY (user_id)
                                     REFERENCES app_user(id)
);


CREATE INDEX idx_audit_inventory_time
    ON audit_event(inventory_id, created_at);


CREATE INDEX idx_audit_user_time
    ON audit_event(user_id, created_at);


CREATE INDEX idx_audit_entity
    ON audit_event(entity_type, entity_id);


CREATE INDEX idx_audit_correlation
    ON audit_event(correlation_id);


CREATE INDEX idx_audit_operation
    ON audit_event(operation_id);


-- Los eventos de auditoría tampoco deben alterarse.
CREATE TRIGGER trg_audit_event_immutable
    BEFORE UPDATE OR DELETE ON audit_event
FOR EACH ROW
EXECUTE FUNCTION prevent_immutable_mutation();


-- =========================================================
-- APPLICATION ERRORS
-- Índice de errores relevantes
-- =========================================================

CREATE TABLE application_error (
                                   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

                                   correlation_id UUID,

                                   user_id UUID,
                                   inventory_id UUID,

    -- Ej. INVENTORY_001, AUTH_003...
                                   error_code VARCHAR(80),

    -- INFO, WARNING, ERROR, CRITICAL
                                   severity VARCHAR(20) NOT NULL DEFAULT 'ERROR',

                                   message VARCHAR(1000) NOT NULL,

                                   exception_class VARCHAR(255),

                                   source VARCHAR(50),

                                   http_method VARCHAR(10),
                                   request_path VARCHAR(500),
                                   http_status INTEGER,

    -- Permite agrupar errores iguales
                                   fingerprint VARCHAR(128),

    -- Datos técnicos sanitizados.
    -- Nunca passwords, tokens o secretos.
                                   metadata JSONB NOT NULL DEFAULT '{}'::jsonb,

                                   resolved BOOLEAN NOT NULL DEFAULT FALSE,

                                   resolved_at TIMESTAMPTZ,
                                   resolved_by_user_id UUID,

                                   resolution_notes VARCHAR(1000),

                                   created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

                                   CONSTRAINT fk_error_user
                                       FOREIGN KEY (user_id)
                                           REFERENCES app_user(id),

                                   CONSTRAINT fk_error_inventory
                                       FOREIGN KEY (inventory_id)
                                           REFERENCES inventory(id),

                                   CONSTRAINT fk_error_resolved_by
                                       FOREIGN KEY (resolved_by_user_id)
                                           REFERENCES app_user(id)
);


CREATE INDEX idx_error_created_at
    ON application_error(created_at);


CREATE INDEX idx_error_code
    ON application_error(error_code);


CREATE INDEX idx_error_correlation
    ON application_error(correlation_id);


CREATE INDEX idx_error_unresolved
    ON application_error(resolved)
    WHERE resolved = FALSE;


CREATE INDEX idx_error_fingerprint
    ON application_error(fingerprint);