DROP PROCEDURE IF EXISTS `SP_DEL_BUSINESS`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DEL_BUSINESS`(IN `i_id` INT UNSIGNED, OUT `o_result` TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET o_result = 3;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;
	
	IF (SELECT 1 = 1 FROM `co_business` WHERE `bu_id` = i_id) THEN
		UPDATE `co_business`
		SET `bu_valid` = 0
		WHERE `bu_id`  = i_id;
		
		SET o_result = 1;
	ELSE
		SET o_result = 2;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;