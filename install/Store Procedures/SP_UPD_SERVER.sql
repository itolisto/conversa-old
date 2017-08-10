DROP PROCEDURE IF EXISTS `SP_UPD_SERVER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_SERVER`(IN `i_id`	    TINYINT UNSIGNED,
															IN `i_name`     VARCHAR(100) CHARSET utf8,
															IN `i_url`      VARCHAR(255) CHARSET utf8,
															IN `i_modified` INT UNSIGNED,
															OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET o_result = 3;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;

	IF (SELECT 1 = 1 FROM `co_servers` WHERE `se_id` = i_id LIMIT 1) THEN
		UPDATE `co_servers`
		SET `se_name` 	  = i_name,
			`se_url` 	  = i_url,
			`se_modified` = i_modified
		WHERE `se_id` = i_id;
		#regresar un valor de exito
		SET o_result = 1;
	ELSE
		#regresar un valor de error
		SET o_result = 2;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;