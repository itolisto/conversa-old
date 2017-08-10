DROP PROCEDURE IF EXISTS `SP_UPD_CATEGORY`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_CATEGORY`(IN `i_id`	      TINYINT UNSIGNED,
															  IN `i_title`    VARCHAR(30)  CHARSET utf8,
															  IN `i_picture`  VARCHAR(155) CHARSET utf8,
															  IN `i_modified` INT UNSIGNED,
															  OUT `o_result`  TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SET o_result = 3;
		SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;

	IF (SELECT 1 = 1 FROM `co_category` WHERE `ca_id` = i_id LIMIT 1) THEN
		IF (SELECT 1 = 1 FROM `co_category` WHERE `ca_title` = i_id LIMIT 1) THEN
			UPDATE `co_category`
			SET `ca_title` 	  = i_title,
				`ca_file_id`  = i_picture,
				`ca_modified` = i_modified
			WHERE `ca_id` = i_id;
			SET o_result = 1;
		ELSE
			SET o_result = 2;
		END IF;
	ELSE
		SET o_result = 2;
	END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;