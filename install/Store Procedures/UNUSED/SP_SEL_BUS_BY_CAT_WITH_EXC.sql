DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_CAT_WITH_EXC`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_CAT_WITH_EXC`(IN `i_business_id`  INT UNSIGNED,
																	     IN `i_category_id`  INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
	SELECT
		b.`bu_id`    				AS _id,
		b.`bu_name`  				AS name,
		b.`bu_about` 				AS about,
		b.`bu_avatar_thumb_file_id` AS avatar_thumb_file_id,
		b.`bu_id_category` 			AS id_category
	FROM `co_business` b
	WHERE b.`bu_id` <> i_business_id AND b.`bu_id_category` = i_category_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;