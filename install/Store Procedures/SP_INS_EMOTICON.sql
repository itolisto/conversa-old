DROP PROCEDURE IF EXISTS `SP_INS_EMOTICON`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_EMOTICON`(IN `i_name`     VARCHAR(25) CHARSET utf8,
                                                              IN `i_file_id`  VARCHAR(155) CHARSET utf8,
                                                              IN `i_created`  INT UNSIGNED,
                                                              OUT `o_id`      TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_id = 3;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_emoticon` WHERE `em_name` = i_name) THEN
        SET o_id = 2;
    ELSE
        INSERT INTO `co_emoticon` (
          `em_name`,
          `em_file_id`,
          `em_created`)
        VALUES (
          i_name,
          i_file_id,
          i_created);

        SET o_id = 1;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;