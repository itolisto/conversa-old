DROP PROCEDURE IF EXISTS `SP_UPD_MESSAGE_READ_AT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_MESSAGE_READ_AT`(IN `i_from_user_id` 	INT UNSIGNED,
														     		 IN `i_to_user_id` 		INT UNSIGNED,
														     		 IN `i_from_user_type` 	TINYINT UNSIGNED,
														     		 IN `i_to_user_type` 	TINYINT UNSIGNED,
														     		 IN `i_new_read_at` 	INT UNSIGNED,
														     		 OUT `o_total` 			INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE x INT;
	SELECT COUNT(*)
	INTO x
	FROM `co_message`
	WHERE `me_from_user_id`   = i_from_user_id
	AND   `me_to_user_id`     = i_to_user_id
	AND   `me_from_user_type` = i_from_user_type
	AND   `me_to_user_type`   = i_to_user_type
	AND   `me_message_target_type` = 1
	AND   `me_read_at` = 0;

	IF (x > 0) THEN
		UPDATE `co_message`
	    SET `me_read_at` = i_new_read_at
		WHERE `me_from_user_id`   = i_from_user_id  AND `me_from_user_type` = i_from_user_type
		AND   `me_to_user_id`     = i_to_user_id    AND `me_to_user_type`   = i_to_user_type
		AND   `me_message_target_type` = 1          AND `me_read_at` 	    = 0;
	END IF;

	SET o_total = x;
END$$
# change the delimiter back to semicolon
DELIMITER ;