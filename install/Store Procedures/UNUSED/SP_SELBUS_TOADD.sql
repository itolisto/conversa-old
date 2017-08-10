/*
 * METODO QUE LO LLAMA: verifyBusinessIsContact
 */
DROP PROCEDURE IF EXISTS `SP_SELBUS_TOADD`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SELBUS_TOADD`(IN `i_id` 	 INT UNSIGNED,
															  OUT `o_result` INT UNSIGNED,
															  OUT `o_stop`   INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

IF (SELECT 1 = 1 FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_id AND `bpt_add_turn` = 1 LIMIT 1) THEN
    BEGIN
    	#Solo para el caso de negocio a usuario
        SELECT `bpt_id` INTO o_result FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_id AND `bpt_add_turn` = 1 LIMIT 1;
        SET o_stop = 0;
    END;
ELSE
    BEGIN
    	DECLARE x INT;
		SELECT COUNT(*) INTO x FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_id;

		IF (x = 0) THEN
			BEGIN
				# No hay dispositivos y se evita todo el proceso posterior
				SET o_stop = 1;
			END;
		ELSE
			BEGIN
				# Si hay dispositivos pero ya se dio la vuelta.
				SET o_stop = 0;
			END;
		END IF;

		SET o_result = 0;
    END;
END IF$$
# change the delimiter back to semicolon
DELIMITER ;