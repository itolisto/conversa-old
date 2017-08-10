DROP PROCEDURE IF EXISTS `SP_INS_MESSAGE`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_MESSAGE`(IN `i_from_user_id`         INT UNSIGNED,
                                                             IN `i_to_user_id`           INT UNSIGNED,
                                                             IN `i_from_user_type`       INT UNSIGNED,
                                                             IN `i_to_user_type`         INT UNSIGNED,
                                                             IN `i_message`              VARCHAR(1200) CHARSET utf8,
                                                             IN `i_created`              INT UNSIGNED,
                                                             IN `i_message_type`         INT UNSIGNED,
                                                             IN `i_message_target_type`  TINYINT UNSIGNED,
                                                             IN `i_picture`              VARCHAR(155) CHARSET utf8,
                                                             IN `i_longitude`            FLOAT,
                                                             IN `i_latitude`             FLOAT,
                                                             IN `i_location`             INT UNSIGNED,
                                                             OUT `o_id`                  INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN
    DECLARE active TINYINT DEFAULT 1;
    DECLARE EXIT HANDLER FOR 1051
    BEGIN
        SET o_id = 0;
        SELECT 'Please create table co_message first';
    END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_id = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
        # If you declare it inside the  BEGIN END block of a stored procedure, it will terminate stored procedure immediately.
    END;

    # Is business
    IF i_to_user_type = 1 THEN
        SET active = FT_IS_LOCATION_ACTIVE(i_to_user_id, i_location);
    END IF;

    IF active = 1 THEN
        INSERT INTO `co_message` (
            `me_from_user_id`,
            `me_to_user_id`,
            `me_created`,
            `me_from_user_type`,
            `me_to_user_type`,
            `me_message_target_type`,
            `me_body`,
            `me_message_type`,
            `me_picture_file_id`,
            `me_longitude`,
            `me_latitude`)
        VALUES (
            i_from_user_id,
            i_to_user_id,
            i_created,
            i_from_user_type,
            i_to_user_type,
            i_message_target_type,
            i_message,
            i_message_type,
            i_picture,
            i_longitude,
            i_latitude);

        SET o_id = LAST_INSERT_ID();
    ELSE
        SET o_id = 0;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;