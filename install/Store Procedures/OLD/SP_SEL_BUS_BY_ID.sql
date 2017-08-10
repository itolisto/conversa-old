DROP PROCEDURE IF EXISTS `SP_SEL_BUS_BY_ID`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_BY_ID`(IN `i_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SELECT
		`bu_id` 					AS `_id`,
	  	`bu_name`					AS `name`,
	  	`bu_email`					AS `email`,
	  	`bu_password`				AS `password`,
	  	`bu_about`					AS `about`,
	  	`bu_founded`				AS `founded`,
	  	`bu_avatar_file_id` 		AS `avatar_file_id`,
	  	`bu_avatar_thumb_file_id`	AS `avatar_thumb_file_id`,
	  	`bu_created`				AS `created`,
	  	`bu_country`				AS `country`,
	  	`bu_id_category`			AS `id_category`,
	  	`bu_paid_plan`				AS `plan`,
	  	`bu_max_devices`       		AS `max_devices_count`,
	  	`bu_diffusion`				AS `diffusion`,
	  	`bu_plan_expiration`		AS `expiration`,
	  	`bu_conversa_id`			AS `conversa_id`
	FROM `co_business` WHERE `bu_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;