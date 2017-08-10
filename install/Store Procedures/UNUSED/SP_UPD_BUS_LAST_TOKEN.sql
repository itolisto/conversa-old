DROP PROCEDURE IF EXISTS `SP_UPD_BUS_LAST_TOKEN`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_BUS_LAST_TOKEN`(IN `i_id` 		  INT UNSIGNED,
															   	    IN `i_token` 	  VARCHAR(100) CHARSET utf8,
															        IN `i_last_login`  INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE hasUpdate INT;

	SELECT  COUNT(1)
	INTO 	hasUpdate
	FROM 	`co_business_push_tokens` WHERE `bpt_business_id` = i_id AND `bpt_status` = 1;
	# Procedimiento para todos los dispositivos activos y se registra uno nuevo

	IF hasUpdate > 0 THEN
		# Se sobreescribe el primer dispositivo registrado (token)
		BEGIN
    		UPDATE `co_business_push_tokens`
			SET    `bpt_last_login` = i_last_login,
				   `bpt_os_type`	= 0,
				   `bpt_status`		= 2,
				   `bpt_token`		= i_token,
				   `bpt_push_token` = ''
			WHERE  `bpt_business_id` = i_id AND `bpt_status` = 1
			LIMIT 1;
		END;
	ELSE
		# Ya se dio la vuelta a todos los dispositivos y ahora toca reiniciar la vuelta
		BEGIN
			# Se actualizan todos los registros para ponerlos en estado de siguiente
    		UPDATE `co_business_push_tokens`
			SET    `bpt_status` 	 = 1
			WHERE  `bpt_business_id` = i_id;
			# Se sobreescribe el primer dispositivo registrado (token)
			UPDATE `co_business_push_tokens`
			SET    `bpt_last_login` = i_last_login,
				   `bpt_os_type`	= 0,
				   `bpt_status`		= 2,
				   `bpt_token`		= i_token,
				   `bpt_push_token` = ''
			WHERE  `bpt_business_id` = i_id AND `bpt_status` = 1
			LIMIT 1;
		END;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;