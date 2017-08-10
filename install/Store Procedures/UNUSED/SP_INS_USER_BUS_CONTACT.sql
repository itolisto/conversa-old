/*
 * METODO QUE LO LLAMA: verifyBusinessIsContact
 */
DROP PROCEDURE IF EXISTS `SP_INS_USER_BUS_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_USER_BUS_CONTACT`(IN `i_user_id`	 	INT UNSIGNED,
															   	 	  IN `i_contact_id` 	INT UNSIGNED,
															   	 	  IN `i_created` 	INT UNSIGNED,
															   	 	  IN `i_buss_push_id`INT UNSIGNED,
															   	 	  OUT `o_result`    	INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN

	IF (SELECT 1 = 1 FROM `co_business_contact` WHERE `bc_user_id` = i_user_id AND `bc_contact_user_id` = i_contact_id AND `bc_business_push_id` = i_buss_push_id AND `bc_contact_business_id` = 0 LIMIT 1) THEN
        BEGIN
            # Ya estaba agregado
            SET o_result = 0;
        END;
    ELSE
        BEGIN
            # Agregar
        	INSERT INTO `co_business_contact` (
			`bc_user_id`,
			`bc_contact_business_id`,
			`bc_contact_user_id`,
			`bc_business_push_id`,
			`bc_created`)
			VALUES (i_user_id, 0, i_contact_id, i_buss_push_id, i_created);

			SET o_result = 1;
        END;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;