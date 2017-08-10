/*
 * METODO QUE LLAMA: addContact
 */
DROP PROCEDURE IF EXISTS `SP_SELUSER_IS_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SELUSER_IS_CONTACT`(IN `i_id` 	   	  INT UNSIGNED,
															 		IN `i_contact_id` INT UNSIGNED,
															 		OUT `o_result`    INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

IF (SELECT 1 = 1 FROM `co_user_contact` WHERE `uc_user_id` = i_id AND `uc_contact_business_id` = i_contact_id LIMIT 1) THEN
    BEGIN
        SET o_result = 1;
    END;
ELSE
    BEGIN
        SET o_result = 0;
    END;
END IF$$
# change the delimiter back to semicolon
DELIMITER ;