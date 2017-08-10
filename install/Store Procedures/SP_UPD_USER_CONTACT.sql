/*
 * METODO QUE LO LLAMA: removeContact
 */
DROP PROCEDURE IF EXISTS `SP_UPD_USER_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_USER_CONTACT`(IN `i_user_id`    INT UNSIGNED,
                                                                  IN `i_contact_id` INT UNSIGNED,
                                                                  OUT `o_result`    TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE id INT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    SELECT `uc_id`
    INTO id
    FROM `co_user_contact`
    WHERE `uc_user_id` = i_user_id AND `uc_contact_business_id` = i_contact_id LIMIT 1;

    IF (id IS NOT NULL) THEN

        UPDATE `co_user_contact`
        SET    `uc_valid` = 0
        WHERE  `uc_id` = id;

        SET o_result = 1;
    ELSE
        SET o_result = 2;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;