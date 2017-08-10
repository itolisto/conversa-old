DROP PROCEDURE IF EXISTS `SP_FIND_BUS_TO_PUSH`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_FIND_BUS_TO_PUSH`(IN `i_bussines_id`  INT UNSIGNED,
                                                                  IN `i_user_id`      INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    IF (SELECT 1 = 1 FROM `co_business_contact` WHERE `bc_user_id` = i_bussines_id AND `bc_contact_user_id` = i_user_id LIMIT 1) THEN
        # Ya es contacto y ya se tiene su push token y os
        SELECT p.`bpt_os_type` AS os_type, p.`bpt_push_token` AS push_token
        FROM `co_business_push_tokens` p
        WHERE p.`bpt_id` = (
            SELECT c.`bc_business_push_id` FROM `co_business_contact` c WHERE c.`bc_user_id` = i_bussines_id AND c.`bc_contact_user_id` = i_user_id LIMIT 1
        )
        LIMIT 1;
    ELSE
    BEGIN
        # Verificar que hayan dispositivos registrados
        DECLARE count INT UNSIGNED DEFAULT 0;

        SELECT COUNT(1)
        INTO   count
        FROM   `co_business_push_tokens`
        WHERE  `bpt_business_id` = i_bussines_id;

        IF count > 0 THEN
        BEGIN
            # No es contacto y se agrega
            DECLARE id INT UNSIGNED DEFAULT 0;

            IF (SELECT 1 = 1 FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_bussines_id AND `bpt_push_turn` = 1 LIMIT 1) THEN
                # Guardar id
                SELECT `bpt_id` INTO id FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_bussines_id AND `bpt_push_turn` = 1 LIMIT 1;
            ELSE
                # Ya se dio la vuelta a los dispositivos, se reinicia la cuenta
                UPDATE `co_business_push_tokens` SET `bpt_push_turn` = 1 WHERE `bpt_business_id` = i_bussines_id;
                # Guardar id
                SELECT `bpt_id` INTO id FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_bussines_id AND `bpt_push_turn` = 1 LIMIT 1;
            END IF;

            # Se actualiza para escoger el proximo dispositivo del negocio
            UPDATE `co_business_push_tokens` SET `bpt_push_turn` = 2 WHERE `bpt_id` = id;
            # Obtiene los datos del negocio para enviar notificacion
            SELECT `bpt_os_type` AS os_type, `bpt_push_token` AS push_token FROM `co_business_push_tokens` WHERE `bpt_id` = id;
        END;
        END IF;
    END;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;