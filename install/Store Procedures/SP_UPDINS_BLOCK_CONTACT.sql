/*
 * METODO QUE LO INVOCA: blockContact
 */
DROP PROCEDURE IF EXISTS `SP_UPDINS_BLOCK_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPDINS_BLOCK_CONTACT`(IN `i_id`          INT UNSIGNED,
                                                                      IN `i_target_id`   INT UNSIGNED,
                                                                      IN `i_type`        TINYINT UNSIGNED,
                                                                      IN `i_target_type` TINYINT UNSIGNED,
                                                                      IN `i_action`      TINYINT UNSIGNED,
                                                                      IN `i_created`     INT UNSIGNED,
                                                                      OUT `o_result`     TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    # Obtener id de registro
    DECLARE id INT UNSIGNED;

    # UNBLOCK
    IF i_action = 0 THEN
        SELECT `blc_id`
        INTO id
        FROM  `co_block_contacts`
        WHERE `blc_from_id`   = i_id
        AND   `blc_from_type` = i_type
        AND   `blc_to_id`     = i_target_id
        AND   `blc_to_type`   = i_target_type
        AND   `blc_valid`     = 1 LIMIT 1;

        IF (id IS NOT NULL) THEN
            # Actualiza a invalido
            UPDATE `co_block_contacts`
            SET    `blc_valid`    = 0,
                   `blc_modified` = i_created
            WHERE  `blc_id`    = id;
            # Ya existia el registro. Se actualiza y regresa exito para desbloqueo
            SET o_result = 1;
        ELSE
            # No existe registro de bloqueo. Se regresa exito para desbloqueo.
            SET o_result = 2;
        END IF;
    ELSE
        # BLOCK
        IF i_action = 1 THEN
            SELECT `blc_id`
            INTO id
            FROM  `co_block_contacts`
            WHERE `blc_from_id`   = i_id
            AND   `blc_from_type` = i_type
            AND   `blc_to_id`     = i_target_id
            AND   `blc_to_type`   = i_target_type LIMIT 1;

            IF (id IS NOT NULL) THEN
                # Actualiza a valido
                UPDATE `co_block_contacts`
                SET    `blc_valid`    = 1,
                       `blc_modified` = i_created
                WHERE  `blc_id`    = id;
                # Ya existia el registro. Se actualiza y regresa exito para bloqueo
                SET o_result = 2;
            ELSE
                INSERT INTO `co_block_contacts` (
                `blc_from_id`,
                `blc_to_id`,
                `blc_from_type`,
                `blc_to_type`,
                `blc_created`)
                VALUES (i_id, i_target_id, i_type, i_target_type, i_created);

                # Exito
                SET o_result = 1;
            END IF;
        ELSE
            # Action not defined
            SET o_result = 0;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;