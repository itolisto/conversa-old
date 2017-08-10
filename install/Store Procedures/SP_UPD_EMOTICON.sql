DROP PROCEDURE IF EXISTS `SP_UPD_EMOTICON`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_EMOTICON`(IN `i_id`	      INT UNSIGNED,
															  IN `i_title`    VARCHAR(25) CHARSET utf8,
															  IN `i_picture`  VARCHAR(155) CHARSET utf8,
															  IN `i_modified` INT UNSIGNED,
															  OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET o_result = 0;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;

	IF (SELECT 1 = 1 FROM `co_emoticon` WHERE `em_id` = i_id LIMIT 1) THEN
		UPDATE `co_emoticon`
		SET `em_name` 	  = i_title,
			`em_file_id`  = i_picture,
			`em_modified` = i_modified
		WHERE `em_id` = i_id;
		#regresar un valor de exito
		SET o_result = 1;
	ELSE
		#regresar un valor de error
		SET o_result = 2;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;