DROP PROCEDURE IF EXISTS `SP_INS_BUSINESS`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_BUSINESS`(IN `i_created`        INT UNSIGNED,
                                                              IN `i_max_devices`    SMALLINT  UNSIGNED,
                                                              IN `i_country`        TINYINT UNSIGNED,
                                                              IN `i_category_id`    TINYINT UNSIGNED,
                                                              IN `i_paid_plan`      TINYINT UNSIGNED,
                                                              IN `i_founded`        DATE,
                                                              IN `i_expiration`     DATE,
                                                              IN `i_name`           VARCHAR(75)  CHARSET utf8,
                                                              IN `i_conversa_id`    VARCHAR(7)   CHARSET utf8,
                                                              IN `i_email`          VARCHAR(255) CHARSET utf8,
                                                              IN `i_password`       VARCHAR(32)  CHARSET utf8,
                                                              IN `i_about`          VARCHAR(180) CHARSET utf8,
                                                              IN `i_picture`        VARCHAR(155) CHARSET utf8,
                                                              IN `i_picture_avatar` VARCHAR(155) CHARSET utf8,
                                                              OUT `o_id`            TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN 
    DECLARE diffusion MEDIUMINT UNSIGNED;
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

    SELECT `pt_diffusion`
    INTO   diffusion
    FROM   `co_plan_type`
    WHERE  `pt_id` = i_paid_plan;

    IF(diffusion IS NOT NULL) THEN
        INSERT INTO `co_business` (
            `bu_created`,
            `bu_max_devices`,
            `bu_diffusion`,
            `bu_country`,
            `bu_id_category`,
            `bu_paid_plan`,
            `bu_founded`,
            `bu_plan_expiration`,
            `bu_name`,
            `bu_conversa_id`,
            `bu_email`,
            `bu_password`,
            `bu_about`,
            `bu_avatar_file_id`,
            `bu_avatar_thumb_file_id`)
        VALUES (
            i_created,
            i_max_devices,
            diffusion,
            i_country,
            i_category_id,
            i_paid_plan,
            i_founded,
            i_expiration,
            i_name,
            i_conversa_id,
            i_email,
            i_password,
            i_about,
            i_picture,
            i_picture_avatar);

        SET o_id = 1;
    ELSE
        SET o_id = 0;
    END IF;
    
END$$
# change the delimiter back to semicolon
DELIMITER ;