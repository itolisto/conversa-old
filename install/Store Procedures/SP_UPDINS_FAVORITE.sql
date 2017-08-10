/*
 * METODO QUE LO INVOCA: addRemoveFavorite
 */
DROP PROCEDURE IF EXISTS `SP_UPDINS_FAVORITE`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPDINS_FAVORITE`(IN `i_id`         INT UNSIGNED,
                                                                 IN `i_target_id`  INT UNSIGNED,
                                                                 IN `i_action`     TINYINT UNSIGNED,
                                                                 IN `i_created`    INT UNSIGNED,
                                                                 OUT `o_result`    TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    # Obtener id de registro
    DECLARE id INT UNSIGNED;

    # REMOVE
    IF i_action = 0 THEN
        SELECT `ufb_id`
        INTO id
        FROM  `co_user_favorite_business`
        WHERE `ufb_user_id`     = i_id
        AND   `ufb_business_id` = i_target_id 
        AND   `ufb_valid`       = 1 LIMIT 1;

        IF (id IS NOT NULL) THEN
            # Exito
            UPDATE `co_user_favorite_business`
            SET    `ufb_valid`    = 0,
                   `ufb_modified` = i_created
            WHERE  `ufb_id` = id;

            SET o_result = 1;
        ELSE
            # No existe registro. Se regresa exito para quitar favorito
            SET o_result = 2;
        END IF;
    ELSE
        # ADD
        IF i_action = 1 THEN
            SELECT `ufb_id`
            INTO id
            FROM  `co_user_favorite_business`
            WHERE `ufb_user_id`     = i_id
            AND   `ufb_business_id` = i_target_id LIMIT 1;

            IF (id IS NOT NULL) THEN
                # Ya esta agregado
                UPDATE `co_user_favorite_business`
                SET    `ufb_valid`    = 1,
                       `ufb_modified` = i_created
                WHERE  `ufb_id` = id;

                SET o_result = 2;
            ELSE
                INSERT INTO `co_user_favorite_business` (
                `ufb_user_id`,
                `ufb_business_id`,
                `ufb_created`,
                `ufb_valid`)
                VALUES (i_id, i_target_id, i_created, 1);

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