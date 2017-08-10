DROP PROCEDURE IF EXISTS `SP_SEL_BUS_COUNT_WITH_CRITERIA`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_COUNT_WITH_CRITERIA`(IN `i_like_name` VARCHAR(255) CHARSET utf8,
																		     OUT `o_count`    INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	IF i_like_name = '' THEN
		SELECT
			COUNT(*) AS count
		INTO o_count
		FROM `co_business`;
	ELSE
		SELECT
			COUNT(*) AS count
		INTO o_count
		FROM `co_business`
		WHERE LOWER(`bu_name`) LIKE LOWER(CONCAT('%',i_like_name,'%'));
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;