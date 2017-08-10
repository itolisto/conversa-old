DROP FUNCTION IF EXISTS `FT_FIND_LOCATION`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FT_FIND_LOCATION`(`i_id` INT UNSIGNED) RETURNS INT UNSIGNED NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE o_result INT;

    SELECT `blo_id` INTO o_result FROM `co_business_location` WHERE `blo_business_id` = i_id AND `blo_valid` = 1 LIMIT 1;

    IF (o_result IS NULL) THEN
    	# No se encontro alguna ubicacion registrada para este negocio
        SET o_result = 0;
    END IF;
    
	RETURN o_result;
END$$
DELIMITER ;