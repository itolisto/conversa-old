DROP PROCEDURE IF EXISTS `SP_INS_BUS_LOCATION`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_BUS_LOCATION`(IN `i_business_id`    INT UNSIGNED,
                                                                  IN `i_contact_number` INT UNSIGNED,
                                                                  IN `i_created`        INT UNSIGNED,
                                                                  IN `i_country`        TINYINT UNSIGNED,
                                                                  IN `i_address`        VARCHAR(150) CHARSET utf8,
                                                                  OUT `o_result`        TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    # Ya esta agregado
    INSERT INTO `co_business_location`(`blo_business_id`,`blo_contact_number`,`blo_added`,`blo_country`,`blo_address`)
    VALUES (i_business_id,i_contact_number,i_created,i_country,i_address);

    SET o_result = 1;
END$$
# change the delimiter back to semicolon
DELIMITER ;