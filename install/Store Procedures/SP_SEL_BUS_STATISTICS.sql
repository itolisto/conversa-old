DROP PROCEDURE IF EXISTS `SP_SEL_BUS_STATISTICS`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SEL_BUS_STATISTICS`(IN `i_id`      INT UNSIGNED,
																    IN `i_push_id` INT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
	SELECT
		(SELECT COUNT(1) FROM `co_business_response`        WHERE `br_id_business`  = i_id) AS `number_of_keys`,
        (SELECT COUNT(1) FROM `co_business_unique_response` WHERE `bur_id_business` = i_id) AS `number_of_first`,
		(SELECT COUNT(1) FROM `co_business_contact`         WHERE `bc_user_id`      = i_id  AND `bc_valid`  = 1) AS `number_contacts`,
        (SELECT COUNT(1) FROM `co_user_favorite_business`   WHERE `ufb_business_id` = i_id  AND `ufb_valid` = 1) AS `number_of_favs`,
        (SELECT COUNT(1) FROM `co_business_location`        WHERE `blo_business_id` = i_id  AND `blo_valid` = 1) AS `number_of_locations`,
        (SELECT COUNT(1) FROM `co_message`                  WHERE `me_from_user_id` = i_id  AND `me_from_user_type` = 1) AS `total_sent`,
        (SELECT COUNT(1) FROM `co_message`                  WHERE `me_to_user_id`   = i_id  AND `me_to_user_type`   = 1) AS `total_received`,
        (SELECT COUNT(1) FROM `co_block_contacts`           WHERE `blc_from_id`     = i_id  AND `blc_from_type`     = 1  AND `blc_valid` = 1) AS `block_contacts`,
        (SELECT COUNT(1) FROM `co_message` m, `co_business_contact` c WHERE m.`me_from_user_id` = i_id AND m.`me_from_user_type` = 1 AND c.`bc_business_push_id` = i_push_id AND c.`bc_valid` = 1) AS `total_sent_by_push`,
        (SELECT COUNT(1) FROM `co_message` m, `co_business_contact` c WHERE m.`me_to_user_id`   = i_id AND m.`me_to_user_type`   = 1 AND c.`bc_business_push_id` = i_push_id AND c.`bc_valid` = 1) AS `total_received_by_push`,
        `co_business`.`bu_max_devices`  AS `max_devices_count`,
        `co_business`.`bu_diffusion`    AS `diffusion`,
        `co_category`.`ca_title`        AS `title`,
        `co_category`.`ca_id`           AS `category_avatar`,
        IF(`co_business`.`bu_plan_expiration` = '0000-00-00', 'forever', `co_business`.`bu_plan_expiration`) AS `expiration_date`
	FROM       `co_business`
	INNER JOIN `co_category`
    ON 		   `co_business`.`bu_id_category` = `co_category`.`ca_id`
 	WHERE      `co_business`.`bu_id` = i_id;
END$$
# change the delimiter back to semicolon
DELIMITER ;