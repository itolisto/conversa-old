DROP PROCEDURE IF EXISTS `SP_UPD_MESSAGE_REPORT`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_MESSAGE_REPORT`(IN `i_id_message` INT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER

BEGIN
	# Verifica si existe el mensaje
	IF (SELECT 1 = 1 FROM `co_message` WHERE `me_id` = i_id_message) THEN
		UPDATE `co_message`
	    SET    `me_report_count` = `me_report_count` + 1
		WHERE  `me_id` = i_id_message;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;