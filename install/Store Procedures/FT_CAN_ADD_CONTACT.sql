DROP FUNCTION IF EXISTS `FT_CAN_ADD_CONTACT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `FT_CAN_ADD_CONTACT`(`i_from_id` 	INT UNSIGNED,
																`i_to_id` 		INT UNSIGNED,
																`i_from_type` 	TINYINT UNSIGNED,
																`i_to_type`		TINYINT UNSIGNED) RETURNS TINYINT UNSIGNED NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE o_result TINYINT DEFAULT 1;

    IF (i_from_type > 2 OR i_to_type > 2) THEN
    	# Non valid types
    	SET o_result = 0;
    ELSE
	    IF (SELECT 1 = 1 FROM `co_block_contacts` WHERE `blc_from_id` = i_from_id AND `blc_from_type` = i_from_type AND `blc_to_id` = i_to_id  AND `blc_to_type` = i_to_type AND `blc_valid` = 1) THEN
	    	# Is blocked
	    	SET o_result = 0;
	    END IF;
    END IF;
    
	RETURN o_result;
END$$
DELIMITER ;