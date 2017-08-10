DROP PROCEDURE IF EXISTS `SP_SEL_CONV_HISTORY`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CONV_HISTORY`(IN `i_user_id` INT UNSIGNED,
                                                                  IN `i_count`	INT UNSIGNED,
                                                                  IN `i_offset`	INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
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
	FROM `co_message` WHERE `me_id` IN (
	       SELECT max(`me_id`) FROM `co_message` WHERE `me_from_user_id` = i_user_id GROUP BY `me_to_user_id`
        )
	ORDER BY `me_created` DESC
	LIMIT i_count
	OFFSET i_offset;
END$$
# change the delimiter back to semicolon
DELIMITER ;