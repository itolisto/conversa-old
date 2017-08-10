DROP FUNCTION IF EXISTS `FT_IS_LOCATION_ACTIVE`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FT_IS_LOCATION_ACTIVE`(`i_business_id` INT UNSIGNED, `i_location_id` INT UNSIGNED) RETURNS TINYINT UNSIGNED NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE o_result TINYINT;

    SELECT `bpt_id` INTO o_result FROM `co_business_push_tokens` WHERE `bpt_business_id` = i_business_id AND `bpt_location` = i_location_id LIMIT 1;

    IF (o_result IS NULL) THEN
    	# No se encontro alguna ubicacion registrada para este negocio
        SET o_result = 0;
    ELSE
    	SET o_result = 1;
    END IF;
    
	RETURN o_result;
END$$
DELIMITER ;