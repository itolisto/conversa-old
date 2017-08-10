DROP PROCEDURE IF EXISTS `SP_SEL_CONV_HIS_COUNT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_CONV_HIS_COUNT`(IN `i_user_id` INT UNSIGNED,
																    OUT `o_total`  INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SELECT COUNT(1)
	INTO o_total
	FROM `co_message`
	WHERE `me_id` IN (
		SELECT max(`me_id`) FROM `co_message` WHERE `me_from_user_id` = i_user_id GROUP BY `me_to_user_id`
	);
END$$
# change the delimiter back to semicolon
DELIMITER ;