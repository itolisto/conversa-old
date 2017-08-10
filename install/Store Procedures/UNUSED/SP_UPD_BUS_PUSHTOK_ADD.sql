DROP PROCEDURE IF EXISTS `SP_UPD_BUS_PUSHTOK_ADD`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_BUS_PUSHTOK_ADD`(IN `i_type` 	INT UNSIGNED,
															   	     IN `i_id`	 	INT UNSIGNED,
															         IN `i_add_turn` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
# No limit
IF i_type = 1 THEN
    BEGIN
        UPDATE `co_business_push_tokens`
		SET    `bpt_add_turn` = i_add_turn#2
		WHERE  `bpt_business_id` = i_id AND `bpt_status` = 1
		LIMIT 1;
    END;
ELSE
    BEGIN
        # All
        IF i_type = 2 THEN
            BEGIN
                UPDATE `co_business_push_tokens`
				SET    `bpt_add_turn` = i_add_turn#2
				WHERE  `bpt_business_id` = i_id AND `bpt_status` = 1
				LIMIT 1;
            END;
        END IF;
    END;
END IF$$
# change the delimiter back to semicolon
DELIMITER ;