DROP PROCEDURE IF EXISTS `SP_UPD_BUS_LOCATION`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_BUS_LOCATION`(IN `i_id`             INT UNSIGNED,
                                                                  IN `i_contact_number` INT UNSIGNED,
                                                                  IN `i_modified`       INT UNSIGNED,
                                                                  IN `i_country`        TINYINT UNSIGNED,
                                                                  IN `i_address`        VARCHAR(150) CHARSET utf8,
                                                                  IN `i_status`         TINYINT UNSIGNED,
                                                                  OUT `o_result`        TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    # Ya esta agregado
    UPDATE `co_business_location`
    SET    `blo_contact_number` = i_contact_number,
           `blo_modified`       = i_modified,
           `blo_country`        = i_country,
           `blo_address`        = i_address,
           `blo_valid`          = i_status
    WHERE `blo_id` = i_id;

    SET o_result = 1;
END$$
# change the delimiter back to semicolon
DELIMITER ;