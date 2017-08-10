DROP PROCEDURE IF EXISTS `SP_SELINS_BUS_DEVICE`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SELINS_BUS_DEVICE`(IN `i_id` 		  INT UNSIGNED,
															   	   IN `i_token` 	  VARCHAR(100) CHARSET utf8,
															       IN `i_last_login`  INT UNSIGNED,
															       IN `i_os`		  TINYINT UNSIGNED,
															       OUT `o_result` 	  TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN

	DECLARE maxDevices INT DEFAULT 1;
	DECLARE activeDevices INT DEFAULT 0;
    DECLARE x INT;
    DECLARE hasUpdate INT DEFAULT 0;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	BEGIN
		ROLLBACK;
		SET o_result = 0;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;

	# Obtener cuenta de dispositivos
	SELECT (SELECT COUNT(*) FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_id), `bu_max_devices`
	INTO 	 activeDevices, maxDevices
	FROM 	`co_business`
	WHERE 	`bu_id` = i_id;

	SET x = FT_FIND_LOCATION(i_id);

	IF x = 0 THEN
		# ERROR: No hay localizaciones registradas para este negocio
		SET o_result = 0;
	ELSE
		IF activeDevices < maxDevices THEN
			# Agregar nuevo dispositivo
			INSERT INTO `co_business_push_tokens` (
			`bpt_business_id`,
			`bpt_token`,
			`bpt_last_login`,
			`bpt_location`,
			`bpt_os_type`)
			VALUES (i_id, i_token, i_last_login, x, i_os);

			SET o_result = 1;
		ELSE
			IF activeDevices = maxDevices THEN
				# Actualizar dispositivos
				SELECT  COUNT(1)
				INTO 	hasUpdate
				FROM 	`co_business_push_tokens` WHERE `bpt_business_id` = i_id AND `bpt_status` = 1;

				IF hasUpdate = 0 THEN
					# Ya se dio la vuelta a todos los dispositivos y ahora toca reiniciar la vuelta
					# Se actualizan todos los registros para ponerlos en estado de siguiente
		    		UPDATE `co_business_push_tokens`
					SET    `bpt_status` 	 = 1
					WHERE  `bpt_business_id` = i_id;
				END IF;

				# Se sobreescribe el primer dispositivo registrado (token)
				UPDATE `co_business_push_tokens`
				SET    `bpt_last_login` = i_last_login,
					   `bpt_os_type`	= i_os,
					   `bpt_status`		= 2,
					   `bpt_token`		= i_token,
					   `bpt_push_token` = '',
					   `bpt_location`   = x
				WHERE  `bpt_business_id` = i_id AND `bpt_status` = 1
				LIMIT 1;
				SET o_result = 1;
			ELSE
				# ERROR: No pueden haber mas dispositivos activos que permitidos
				SET o_result = 0;
			END IF;
		END IF;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;