DROP PROCEDURE IF EXISTS `SP_INS_SERVER`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_INS_SERVER`(IN `i_name`      VARCHAR(100) CHARSET utf8,
                                                            IN `i_url`       VARCHAR(255) CHARSET utf8,
                                                            IN `i_created`   INT UNSIGNED,
                                                            OUT `o_id`       TINYINT UNSIGNED) NOT DETERMINISTIC MODIFIES SQL DATA SQL SECURITY DEFINER
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET o_id = 0;
        SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
    END;

    IF (SELECT 1 = 1 FROM `co_servers` WHERE `se_url` = i_url OR `se_name` = i_name) THEN
        SET o_id = 2;
    ELSE
        INSERT INTO `co_servers` (
            `se_name`,
            `se_url`,
            `se_created`)
        VALUES (
            i_name,
            i_url,
            i_created);

        SET o_id = 1;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;