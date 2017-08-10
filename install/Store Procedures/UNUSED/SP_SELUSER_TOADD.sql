/*
 * METODO QUE LO USA: addContactBusiness
 */
DROP PROCEDURE IF EXISTS `SP_SELUSER_TOADD`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SELUSER_TOADD`(IN `i_business_id` INT UNSIGNED,
															   IN `i_contact_id`  INT UNSIGNED,
															   IN `i_buspush_id`  INT UNSIGNED,
															   OUT `o_result`	  INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

IF (SELECT 1 = 1 FROM `co_business_contact` WHERE `bc_user_id` = i_business_id AND `bc_contact_user_id` = i_contact_id AND `bc_business_push_id` = i_buspush_id LIMIT 1) THEN
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