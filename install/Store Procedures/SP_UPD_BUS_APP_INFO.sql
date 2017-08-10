DROP PROCEDURE IF EXISTS `SP_UPD_BUS_APP_INFO`;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_UPD_BUS_APP_INFO`(IN `i_action`        TINYINT UNSIGNED,
														  	      IN `i_id`            INT UNSIGNED,
                                                                  IN `i_token`         VARCHAR(100) CHARSET utf8,
                                                                  IN `i_time_modified` INT UNSIGNED,
                                                                  IN `i_value`         VARCHAR(255) CHARSET utf8,
                                                                  OUT `o_result`       TINYINT UNSIGNED) NOT DETERMINISTIC READS SQL DATA SQL SECURITY DEFINER

BEGIN
    DECLARE x INT DEFAULT 1;

    # iOS Token
    IF i_action = 1 THEN
        # Limpiar tokens parecidos
        UPDATE `co_business_push_tokens`
        SET    `bpt_push_token` = '',
               `bpt_os_type`    = 0
        WHERE  `bpt_business_id` = i_id AND `bpt_token` = i_token AND `bpt_push_token` = i_value AND `bpt_os_type` = 1;
        # Actualizar
        UPDATE `co_business_push_tokens`
        SET    `bpt_push_token` = i_value,
               `bpt_os_type`    = 1
        WHERE  `bpt_business_id` = i_id AND `bpt_token` = i_token;
    ELSE
    	# Android Token
        IF i_action = 2 THEN
            # Limpiar tokens parecidos
            UPDATE `co_business_push_tokens`
            SET    `bpt_push_token` = '',
                   `bpt_os_type`    = 0
            WHERE  `bpt_business_id` = i_id AND `bpt_token` = i_token AND `bpt_push_token` = i_value AND `bpt_os_type` = 2;
            # Actualizar
            UPDATE `co_business_push_tokens`
            SET    `bpt_push_token` = i_value,
                   `bpt_os_type`    = 2
            WHERE  `bpt_business_id` = i_id AND `bpt_token` = i_token;
        ELSE
    		# Email
            IF i_action = 3 THEN
                UPDATE  `co_business`
                SET     `bu_email`    = i_value,
                        `bu_modified` = i_time_modified
                WHERE   `bu_id` = i_id;
            ELSE
                # Nombre de usuario
                IF i_action = 4 THEN
                    UPDATE  `co_business`
                    SET     `bu_name`     = i_value,
                            `bu_modified` = i_time_modified
                    WHERE   `bu_id` = i_id;
                ELSE
                    # Password
                    IF i_action = 5 THEN
                        UPDATE  `co_business`
                        SET     `bu_password` = i_value,
                                `bu_modified` = i_time_modified
                        WHERE   `bu_id` = i_id;
                    ELSE
                        # ERROR
                        SET x = 0;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;

    IF x = 1 THEN
        SET o_result = 1;
    ELSE
        SET o_result = 0;
    END IF;
END$$
# change the delimiter back to semicolon
DELIMITER ;