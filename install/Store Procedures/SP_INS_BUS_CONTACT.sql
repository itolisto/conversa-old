/*
 * METODO QUE LO INVOCA: addContactBusiness
 */
DROP PROCEDURE IF EXISTS `SP_INS_BUS_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_BUS_CONTACT`(IN `i_user_id`	    INT UNSIGNED,
															   	 IN `i_contact_id`  INT UNSIGNED,
															   	 IN `i_buspush_id`  INT UNSIGNED,
															   	 IN `i_created`     INT UNSIGNED,
															   	 IN `i_from_type`   INT UNSIGNED,
															   	 IN `i_to_type`     INT UNSIGNED,
															   	 OUT `o_result`     INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE x TINYINT;
	DECLARE pushId INT UNSIGNED;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET o_result = 3;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;

	SET x = FT_CAN_ADD_CONTACT(i_contact_id, i_user_id, i_to_type, i_from_type);

	IF x = 1 THEN
		# Verificar si usuario ya tiene de contacto a este negocio
		IF (SELECT 1 = 1 FROM `co_business_contact` WHERE `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 AND `bc_business_push_id` = i_buspush_id LIMIT 1) THEN
	    	# Verificar estado (1: Valido 2: No valido)
	    	IF (SELECT 1 = 1 FROM `co_business_contact` WHERE `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 AND `bc_business_push_id` = i_buspush_id AND `bc_valid` = 1 LIMIT 1) THEN
	    		SET o_result = 0;
    		ELSE
				# Actualizar estado
    			UPDATE `co_business_contact`
    			SET    `bc_valid` = 1
    			WHERE  `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 AND `bc_business_push_id` = i_buspush_id AND `bc_valid` = 0;

    			SET o_result = 0;
    		END IF;
		ELSE
			# Si ya esta asociado a un PUSH ID de negocio se actualiza esa referencia
			SELECT `bc_business_push_id` INTO pushId FROM `co_business_contact` WHERE `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 LIMIT 1;
			IF(pushId IS NOT NULL) THEN
				# Actualizar estado
    			UPDATE `co_business_contact`
    			SET    `bc_valid` = 1,
    				   `bc_business_push_id` = i_buspush_id 
    			WHERE  `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_contact_business_id` = 0 AND `bc_business_push_id` = pushId;

    			SET o_result = 0;
    		ELSE
    			# Se agrega contacto
		    	INSERT INTO `co_business_contact` (
				`bc_user_id`,
				`bc_contact_business_id`,
				`bc_contact_user_id`,
				`bc_business_push_id`,
				`bc_created`)
				VALUES (i_user_id, 0, i_contact_id, i_buspush_id, i_created);

				SET o_result = 1;
    		END IF;
		END IF;
	ELSE
		SET o_result = 2;
	END IF;		
END$$
# change the delimiter back to semicolon
DELIMITER ;