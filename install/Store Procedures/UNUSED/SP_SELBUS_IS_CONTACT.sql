/*
 * METODO QUE LO LLAMA: verifyBusinessIsContact
 */
DROP PROCEDURE IF EXISTS `SP_SELBUS_IS_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SELBUS_IS_CONTACT`(IN `i_id` 	  INT UNSIGNED,
															 	   IN `i_coct_id` INT UNSIGNED,
															 	   OUT `o_result` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

IF (SELECT 1 = 1 FROM `co_business_contact` WHERE `bc_user_id` = i_id AND `bc_contact_user_id` = i_coct_id LIMIT 1) THEN
    BEGIN
    	#Solo para el caso de negocio a usuario
        SELECT `bc_id` INTO o_result FROM `co_business_contact` WHERE `bc_user_id` = i_id AND `bc_contact_user_id` = i_coct_id LIMIT 1;
    END;
ELSE
    BEGIN
        SET o_result = 0;
    END;
END IF$$
# change the delimiter back to semicolon
DELIMITER ;