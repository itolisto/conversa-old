DROP PROCEDURE IF EXISTS `SP_SEL_MESSAGES_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_MESSAGES_BY_ID`(IN `i_from_user_id`         INT UNSIGNED,
                                                                    IN `i_from_user_type`       TINYINT UNSIGNED,
                                                                    IN `i_to_user_id`           INT UNSIGNED,
                                                                    IN `i_to_user_type`         TINYINT UNSIGNED,
                                                                    IN `i_message_target_type`  TINYINT UNSIGNED,
                                                                    IN `i_offset`               INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    SELECT
        `co_message`.`me_id`                   AS `_id`,
        `co_message`.`me_from_user_id`         AS `from_user_id`,
        `co_message`.`me_to_user_id`           AS `to_user_id`,
        `co_message`.`me_created`              AS `created`,
        `co_message`.`me_modified`             AS `modified`,
        `co_message`.`me_read_at`              AS `read_at`,
        `co_message`.`me_message_type`         AS `message_type`,
        `co_message`.`me_from_user_type`       AS `from_user_type`,
        `co_message`.`me_to_user_type`         AS `to_user_type`,
        `co_message`.`me_message_target_type`  AS `message_target_type`,
        `co_message`.`me_body`                 AS `body`,
        `co_message`.`me_picture_file_id`      AS `picture_file_id`,
        `co_message`.`me_longitude`            AS `longitude`,
        `co_message`.`me_latitude`             AS `latitude`
    FROM  `co_message`
    WHERE `co_message`.`me_from_user_id`        = i_to_user_id
    AND   `co_message`.`me_from_user_type`      = i_to_user_type
    AND   `co_message`.`me_to_user_id`          = i_from_user_id
    AND   `co_message`.`me_to_user_type`        = i_from_user_type
    AND   `co_message`.`me_message_target_type` = i_message_target_type
    AND   `co_message`.`me_delivered`           = 0
    LIMIT 200;
    #OFFSET i_offset;

    -- # Negocio
    -- IF i_from_user_type = 1 THEN
    --     BEGIN
    --         SELECT
    --             `co_message`.`me_id`                   AS `_id`,
    --             `co_message`.`me_from_user_id`         AS `from_user_id`,
    --             `co_message`.`me_to_user_id`           AS `to_user_id`,
    --             `co_message`.`me_created`              AS `created`,
    --             `co_message`.`me_modified`             AS `modified`,
    --             `co_message`.`me_read_at`              AS `read_at`,
    --             `co_message`.`me_message_type`         AS `message_type`,
    --             `co_message`.`me_from_user_type`       AS `from_user_type`,
    --             `co_message`.`me_to_user_type`         AS `to_user_type`,
    --             `co_message`.`me_message_target_type`  AS `message_target_type`,
    --             `co_message`.`me_body`                 AS `body`,
    --             `co_message`.`me_picture_file_id`      AS `picture_file_id`,
    --             `co_message`.`me_longitude`            AS `longitude`,
    --             `co_message`.`me_latitude`             AS `latitude`
    --         FROM `co_message`
    --         LEFT JOIN `co_user`
    --         ON `co_user`.`us_id` = `co_message`.`me_to_user_id`
    --         LEFT JOIN `co_business`
    --         ON `co_business`.`bu_id` = `co_message`.`me_from_user_id`
    --         WHERE `co_message`.`me_from_user_id`        = i_to_user_id
    --         AND   `co_message`.`me_from_user_type`      = i_to_user_type
    --         AND   `co_message`.`me_to_user_id`          = i_from_user_id
    --         AND   `co_message`.`me_to_user_type`        = i_from_user_type
    --         AND   `co_message`.`me_message_target_type` = i_message_target_type
    --         LIMIT 200
    --         OFFSET i_offset;
    --     END;
    -- ELSE
    --     BEGIN
    --         # Usuario
    --         IF i_from_user_type = 2 THEN
    --             BEGIN
    --                 SELECT
    --                     `co_message`.`me_id`                   AS `_id`,
    --                     `co_message`.`me_from_user_id`         AS `from_user_id`,
    --                     `co_message`.`me_to_user_id`           AS `to_user_id`,
    --                     `co_message`.`me_created`              AS `created`,
    --                     `co_message`.`me_modified`             AS `modified`,
    --                     `co_message`.`me_read_at`              AS `read_at`,
    --                     `co_message`.`me_message_type`         AS `message_type`,
    --                     `co_message`.`me_from_user_type`       AS `from_user_type`,
    --                     `co_message`.`me_to_user_type`         AS `to_user_type`,
    --                     `co_message`.`me_message_target_type`  AS `message_target_type`,
    --                     `co_message`.`me_body`                 AS `body`,
    --                     `co_message`.`me_picture_file_id`      AS `picture_file_id`,
    --                     `co_message`.`me_longitude`            AS `longitude`,
    --                     `co_message`.`me_latitude`             AS `latitude`
    --                 FROM `co_message` 
    --                 LEFT JOIN `co_business`
    --                 ON `co_business`.`bu_id` = `co_message`.`me_to_user_id`
    --                 LEFT JOIN `co_user`
    --                 ON `co_user`.`us_id` = `co_message`.`me_from_user_id`
    --                 WHERE `co_message`.`me_from_user_id`        = i_to_user_id
    --                 AND   `co_message`.`me_from_user_type`      = i_to_user_type
    --                 AND   `co_message`.`me_to_user_id`          = i_from_user_id
    --                 AND   `co_message`.`me_to_user_type`        = i_from_user_type
    --                 AND   `co_message`.`me_message_target_type` = i_message_target_type
    --                 LIMIT 200
    --                 OFFSET i_offset;
    --             END;
    --         END IF;
    --     END;
    -- END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;