/*
 * METODO QUE LO LLAMA: removeContactBusiness
 */
DROP PROCEDURE IF EXISTS `SP_UPD_BUS_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_BUS_CONTACT`(IN `i_business_id`	INT UNSIGNED,
															   	 IN `i_contact_id` 	INT UNSIGNED,
                                                                 IN `i_buspush_id`  INT UNSIGNED,
															   	 OUT `o_result`    	TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    SELECT `bc_id`
    INTO   id
    FROM   `co_business_contact`
    WHERE  `bc_user_id`             = i_business_id
    AND    `bc_contact_user_id`     = i_contact_id
    AND    `bc_contact_business_id` = 0
    AND    `bc_business_push_id`    = i_buspush_id
    AND    `bc_valid`               = 1 LIMIT 1;

    IF (id IS NOT NULL) THEN
        UPDATE `co_business_contact`
        SET    `bc_valid` = 0
        WHERE  `bc_id` = id;

        SET o_result = 1;
    ELSE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;