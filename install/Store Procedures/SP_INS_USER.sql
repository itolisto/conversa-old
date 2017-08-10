DROP PROCEDURE IF EXISTS `SP_INS_USER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_USER`(IN `i_name`          VARCHAR(255) CHARSET utf8,
                                                          IN `i_email`         VARCHAR(255) CHARSET utf8,
                                                          IN `i_password`      VARCHAR(110) CHARSET utf8,
                                                          IN `i_birthday`      DATE,
                                                          IN `i_gender`        TINYINT UNSIGNED,
                                                          IN `i_about`         VARCHAR(180) CHARSET utf8,
                                                          IN `i_avatar_file_id`VARCHAR(155) CHARSET utf8,
                                                          IN `i_avatar_thumb_file_id` VARCHAR(155) CHARSET utf8,
                                                          IN `i_created`       INT UNSIGNED,
                                                          IN `i_modified`      INT UNSIGNED,
                                                          OUT `o_result`       TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_result = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_user` WHERE LOWER(`us_email`) = LOWER(i_email)) THEN
        SET `o_result` = 2;
    ELSE
        IF (SELECT 1 = 1 FROM `co_user` WHERE LOWER(`us_name`) = LOWER(i_name)) THEN
            SET `o_result` = 3;
        ELSE
            INSERT INTO `co_user` (
              `us_name`,
              `us_email`,
              `us_password`,
              `us_birthday`,
              `us_gender`,
              `us_about`,
              `us_avatar_file_id`,
              `us_avatar_thumb_file_id`,
              `us_created`,
              `us_modified`)
            VALUES (
              i_name, i_email, i_password, i_birthday, i_gender, i_about,
              i_avatar_file_id, i_avatar_thumb_file_id, i_created, i_modified);

            SET `o_result` = 1;
        END IF;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;