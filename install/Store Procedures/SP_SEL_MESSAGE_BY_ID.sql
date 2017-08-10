DROP PROCEDURE IF EXISTS `SP_SEL_MESSAGE_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_MESSAGE_BY_ID`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN
      SELECT
            `me_id`                   AS `_id`,
            `me_from_user_id`         AS `from_user_id`,
            `me_to_user_id`           AS `to_user_id`,
            `me_created`              AS `created`,
            `me_modified`             AS `modified`,
            `me_read_at`              AS `read_at`,
            `me_message_type`         AS `message_type`,
            `me_from_user_type`       AS `from_user_type`,
            `me_to_user_type`         AS `to_user_type`,
            `me_message_target_type`  AS `message_target_type`,
            `me_body`                 AS `body`,
            `me_picture_file_id`      AS `picture_file_id`,
            `me_longitude`            AS `longitude`,
            `me_latitude`             AS `latitude`
      FROM `co_message`
      WHERE `me_id`  = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;