/*
 * METODO QUE LO LLAMA: addContact
 */
DROP PROCEDURE IF EXISTS `SP_INS_USER_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_USER_CONTACT`(IN `i_user_id`	INT UNSIGNED,
															   	  IN `i_contact_id` INT UNSIGNED,
															   	  IN `i_created` 	INT UNSIGNED,
															   	  IN `i_from_type` 	TINYINT UNSIGNED,
																  IN `i_to_type`	TINYINT UNSIGNED,
															   	  OUT `o_result`    TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE x INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET o_result = 3;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;

	SET x = FT_CAN_ADD_CONTACT(i_contact_id, i_user_id, i_to_type, i_from_type);

	IF x = 1 THEN
		# Verificar si usuario ya tiene de contacto a este negocio
		IF (SELECT 1 = 1 FROM `co_user_contact` WHERE `uc_user_id` = i_user_id AND `uc_contact_business_id` = i_contact_id LIMIT 1) THEN
	    	# Verificar estado (1: Valido 2: No valido)
	    	IF (SELECT 1 = 1 FROM `co_user_contact` WHERE `uc_user_id` = i_user_id AND `uc_contact_business_id` = i_contact_id AND `uc_valid` = 1 LIMIT 1) THEN
	    		SET o_result = 0;
    		ELSE
    			# Actualizar estado
    			UPDATE `co_user_contact`
    			SET    `uc_valid` = 1
    			WHERE  `uc_user_id` = i_user_id AND `uc_contact_business_id` = i_contact_id AND `uc_valid` = 0;

    			SET o_result = 0;
    		END IF;
		ELSE
			# Se agrega contacto
	    	INSERT INTO `co_user_contact` (
			`uc_user_id`,
			`uc_contact_business_id`,
			`uc_created`)
			VALUES (i_user_id, i_contact_id, i_created);

			SET o_result = 1;
		END IF;
	ELSE
		# Bloqueado
		SET o_result = 2;
	END IF;		
END$$
# change the delimiter back to semicolon
DELIMITER ;