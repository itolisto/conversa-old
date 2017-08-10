DROP PROCEDURE IF EXISTS `SP_SEL_SEARCH_BUSINESS_BY_CATEGORY`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_SEARCH_BUSINESS_BY_CATEGORY`(IN `i_user_id`		 INT UNSIGNED,
																	 			 IN `i_target_name`  VARCHAR(30) CHARSET utf8,
																	 			 IN `i_category_id`  INT UNSIGNED,
																	 			 IN `i_count`		 INT UNSIGNED,
																	 			 IN `i_offset`		 INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
		SELECT
			b.`bu_id`    				AS _id,
			b.`bu_name`  				AS name,
			b.`bu_about` 				AS about,
			b.`bu_avatar_thumb_file_id` AS avatar_thumb_file_id,
			b.`bu_id_category` 			AS id_category,
			IF(f.`ufb_id` IS NULL,0,1)  AS favorite
		FROM `co_business` b
		LEFT JOIN `co_user_favorite_business` f
		ON (f.`ufb_user_id` = i_user_id AND b.`bu_id` = f.`ufb_business_id` AND f.`ufb_valid` = 1)
		WHERE b.`bu_conversa_id` = i_target_name
		AND   b.`bu_id_category` = i_category_id
	UNION
		SELECT
			b.`bu_id`    				AS _id,
			b.`bu_name`  				AS name,
			b.`bu_about` 				AS about,
			b.`bu_avatar_thumb_file_id` AS avatar_thumb_file_id,
			b.`bu_id_category` 			AS id_category,
			IF(f.`ufb_id` IS null,0,1)  AS favorite
		FROM `co_business` b
		LEFT JOIN `co_user_favorite_business` f
		ON (f.`ufb_user_id` = i_user_id AND b.`bu_id` = f.`ufb_business_id` AND f.`ufb_valid` = 1)
		WHERE b.`bu_paid_plan` <> 0
		AND   b.`bu_id_category` = i_category_id
		AND   LOWER(b.`bu_name`) LIKE LOWER(CONCAT('%',i_target_name,'%'))
		LIMIT  i_count
		OFFSET i_offset;
END$$
# change the delimiter back to semicolon
DELIMITER ;