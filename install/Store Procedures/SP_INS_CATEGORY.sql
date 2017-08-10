DROP PROCEDURE IF EXISTS `SP_INS_CATEGORY`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_CATEGORY`(IN `i_name`     VARCHAR(30)  CHARSET utf8,
                                                              IN `i_file_id`  VARCHAR(155) CHARSET utf8,
                                                              IN `i_created`  INT UNSIGNED,
                                                              OUT `o_id`      TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_id = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_category` WHERE `ca_title` = i_name) THEN
        SET o_id = 2;
    ELSE
        INSERT INTO `co_category` (
          `ca_title`,
          `ca_file_id`,
          `ca_created`)
        VALUES (
          i_name,
          i_file_id,
          i_created);

        SET o_id = 1;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;