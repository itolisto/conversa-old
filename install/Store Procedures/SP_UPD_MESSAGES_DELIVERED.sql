DROP PROCEDURE IF EXISTS `SP_UPD_MESSAGES_DELIVERED`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_MESSAGES_DELIVERED`(IN `i_from_user_id`         INT UNSIGNED,
                                                                    	IN `i_from_user_type`       TINYINT UNSIGNED,
                                                                    	IN `i_to_user_id`           INT UNSIGNED,
                                                                    	IN `i_to_user_type`         TINYINT UNSIGNED,
                                                                    	IN `i_message_target_type`  TINYINT UNSIGNED,
                                                                    	IN `i_offset`               INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
#	DECLARE lastId INT UNSIGNED;
#    
#    SELECT `me_id` INTO lastId
#    FROM   `co_message`
#    WHERE  `co_message`.`me_from_user_id`        = i_to_user_id
#    AND    `co_message`.`me_from_user_type`      = i_to_user_type
#    AND    `co_message`.`me_to_user_id`          = i_from_user_id
#    AND    `co_message`.`me_to_user_type`        = i_from_user_type
#    AND    `co_message`.`me_message_target_type` = i_message_target_type
#    AND    `co_message`.`me_delivered`           = 0
#    LIMIT 1
#    OFFSET i_offset;
    
	UPDATE `co_message`
    SET    `me_delivered` = 1
    WHERE  `co_message`.`me_from_user_id`        = i_to_user_id
    AND    `co_message`.`me_from_user_type`      = i_to_user_type
    AND    `co_message`.`me_to_user_id`          = i_from_user_id
    AND    `co_message`.`me_to_user_type`        = i_from_user_type
    AND    `co_message`.`me_message_target_type` = i_message_target_type
    AND    `co_message`.`me_delivered`           = 0
    LIMIT 200;
END$$
# change the delimiter back to semicolon
DELIMITER ;