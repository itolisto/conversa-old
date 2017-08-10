<?php

/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Conversa\Controller\Web\Installer;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Symfony\Component\Debug\ExceptionHandler;
use Symfony\Component\HttpFoundation\Request;
use Conversa\Controller\FileController;

class InstallerController implements ControllerProviderInterface {

    public function curPageURLLocal() {
        $pageURL = "http://localhost".$_SERVER["REQUEST_URI"];
        return $pageURL;
    }
    
    public function curPageURL() {
        $pageURL = 'http';
        if (isset($_SERVER["HTTPS"]) && $_SERVER["HTTPS"] == "on") {
            $pageURL .= "s";
        }
        $pageURL .= "://";
        $pageURL .= $_SERVER["HTTP_HOST"].$_SERVER["REQUEST_URI"];
        return $pageURL;
    }

    public function connect(Application $app)  {
        ExceptionHandler::register(false);
        $controllers = $app['controllers_factory'];
        $self = $this;
        
        $controllers->get('/', function (Request $request) use ($app,$self) {
            return $app->redirect(ROOT_URL . '/installer');   
        });
        
        // first screen
        $controllers->get('/installer', function (Request $request) use ($app,$self) {
            $app['monolog']->addDebug("top");
            $rootUrl = str_replace("/installer","",$self->curPageURL());

            return $app['twig']->render('installer/installerTop.twig', array(
                'ROOT_URL' => $rootUrl
            ));         
        });

        // connect to DB
        $controllers->post('/installer/step1', function (Request $request) use ($app,$self) {
            $app['monolog']->addDebug("step1");
            
            $rootUrl    = str_replace("/installer/step1","",$self->curPageURL());
            $host       = $request->get('host');
            $database   = $request->get('database');
            $userName   = $request->get('username');
            $password   = $request->get('password');
            
            $config = new \Doctrine\DBAL\Configuration();
            
            $connectionParams = array(
                'dbname' => $database,
                'user' => $userName,
                'password' => $password,
                'host' => $host,
                'driver' => 'pdo_mysql',
            );
            
            $app['session']->set('databaseConfiguration', $connectionParams);
            $conn = \Doctrine\DBAL\DriverManager::getConnection($connectionParams, $config);
            
            try{
                $connectionResult = $conn->connect();
            }catch(\PDOException $e){
                $connectionResult = false;
                $app['monolog']->addDebug("Failed to connect DB");
            }
            
            if($connectionResult){
                return $app['twig']->render('installer/installerStep1.twig', array(
                    'ROOT_URL' => $rootUrl,
                    'ConnectionSucceed' => $connectionResult
                ));         
            }else{
                return $app['twig']->render('installer/installerTop.twig', array(
                    'ROOT_URL' => $rootUrl,
                    'ConnectionSucceed' => $connectionResult
                ));         
            }
        });

        // create database schema
        $controllers->post('/installer/step2', function (Request $request) use ($app,$self) {
            
            $app['monolog']->addDebug("step2");
            
            $rootUrl = str_replace("/installer/step2","",$self->curPageURL());
            
            $config = new \Doctrine\DBAL\Configuration();
            $connectionParams = $app['session']->get('databaseConfiguration');
            
            $conn = \Doctrine\DBAL\DriverManager::getConnection($connectionParams, $config);
            
            try{
                $connectionResult = $conn->connect();           
            }catch(\PDOException $e){
                $app->redirect('/installer');
            }
//            
//            // read sql file
//            $pathToSchemaFile = "../install/databaseschema.sql";
//            if(!file_exists("../install/databaseschema.sql")){
//                return $app['twig']->render('installer/installerError.twig', array(
//                    'ROOT_URL' => $rootUrl
//                ));
//            }
//            
//            $schemacontent = file_get_contents($pathToSchemaFile);
//            
//            $queries = explode(";",$schemacontent);
//            
//            $conn->beginTransaction();
//            
//            try{
//            
//                foreach($queries as $query){
//                    $query = trim($query);
//                    
//                    if(!empty($query))
//                        $conn->executeQuery($query);
//                }
//                
//                $conn->commit();    
//            } catch(\Exception $e){
//                $app['monolog']->addDebug($e);
//                var_dump($e->getMessage());
//                $conn->rollback();      
//                return $app['twig']->render('installer/installerError.twig', array(
//                    'ROOT_URL' => $rootUrl
//                ));
//                
//            }
            
            return $app['twig']->render('installer/installerStep2.twig', array(
                'ROOT_URL' => $rootUrl,
                'ConnectionSucceed' => $connectionResult
            ));     
        
        });

        // generate initial data
        $controllers->post('/installer/step3', function (Request $request) use ($app,$self) {
            
            $app['monolog']->addDebug("step3");
            
            $rootUrl = str_replace("/installer/step3","",$self->curPageURL());
            $localRootUrl = str_replace("/installer/step3","",$self->curPageURLLocal());
                    
            $config = new \Doctrine\DBAL\Configuration();
            $connectionParams = $app['session']->get('databaseConfiguration');
            
            $conn = \Doctrine\DBAL\DriverManager::getConnection($connectionParams, $config);
            
            try{
                $connectionResult = $conn->connect();           
            }catch(\PDOException $e){
                $app['monolog']->addDebug("failed to connect DB" . var_dump($connectionParams));
                $app['monolog']->addDebug($e->getMessage());
                
                $app->redirect('/installer');
            }
            
            $fileDir = __DIR__.'/../../../../../'.FileController::$fileDirName;
            if(!is_writable($fileDir)){
                $app['monolog']->addDebug("{$fileDir} is not writable.");
                return $app['twig']->render('installer/installerError.twig', array(
                    'ROOT_URL' => $rootUrl
                ));
            }
            
            $conn->beginTransaction();
            
            // generate group categories

            $files = array();
            $filesPath = __DIR__.'/../../../../../install/resouces/categoryimages';
            if ($handle = opendir($filesPath)) {
                while ($entry = readdir($handle)) {
                    if (is_file($filesPath . "/" . $entry)) {
                        if (preg_match("/png/", $entry)) {
                            $files[] = $filesPath . "/" . $entry;
                        }
                    }
                }
                closedir($handle);
            }
            
            foreach ($files as $path) {
                
                // copy to file dir
                $pathinfo = pathinfo($path);
                $categoryName = $pathinfo['filename'];
                $imgbinary = @file_get_contents($path);
                
                $fileName = \Conversa\Utils::randString(FILES_TOKEN_LENGTH, FILES_TOKEN_LENGTH);
                $newFilePath = $fileDir."/category/".$fileName;
                copy($path,$newFilePath);
                
                // create data
                $data = array(
                    'ca_title'    => $categoryName,
                    'ca_file_id'  => $fileName,
                    'ca_created'  => time(),
                    'ca_modified' => 0
                );

                try{
                    $conn->insert('co_category',$data);
                } catch(\Exception $e){
                    $app['monolog']->addDebug($e->getMessage());
                    $conn->rollback();
                    
                    return $app['twig']->render('installer/installerError.twig', array(
                        'ROOT_URL' => $rootUrl
                    ));
                }
            }
            
            // generate emoticons
            $files = array();
            $filesPath = __DIR__.'/../../../../../install/resouces/emoticons';
            if ($handle = opendir($filesPath)) {
            
                while ($entry = readdir($handle)) {
                    if (is_file($filesPath . "/" . $entry)) {
            
                        if (preg_match("/png/", $entry)) {
                            $files[] = $filesPath . "/" . $entry;
                        }
                    }
                }
            
                closedir($handle);
            }
            
            foreach ($files as $path) {
                
                // copy to file dir
                $pathinfo = pathinfo($path);
                $emoticonname = $pathinfo['filename'];
                $imgbinary = @file_get_contents($path);
                
                $fileName = \Conversa\Utils::randString(FILES_TOKEN_LENGTH, FILES_TOKEN_LENGTH);
                $newFilePath = $fileDir."/emoticon/".$fileName;
                copy($path,$newFilePath);
                
                // create data
                $data = array(
                    'em_name' => $emoticonname,
                    'em_file_id' => $fileName,
                    'em_created' => time(),
                    'em_modified' => 0
                );

                try{
                
                    $conn->insert('co_emoticon',$data);
                    
                } catch(\Exception $e){
                    $app['monolog']->addDebug($e->getMessage());
                    $conn->rollback();  
                    
                    return $app['twig']->render('installer/installerError.twig', array(
                        'ROOT_URL' => $rootUrl,
                    ));
                }
            }
            
            // create admin user
            $password = 'password';
            $adminData = array();
            $adminData['ad_name'] = "Administrator";
            $adminData['ad_email'] = "admin@conversa.com";
            $adminData['ad_password'] = md5($password);
            $adminData['ad_birthday'] = '1999-12-25';
            $adminData['ad_created'] = time();
            $conn->insert('co_admins',$adminData);
            
            $userData = array();
            $userData['us_name'] = "Usuario";
            $userData['us_email'] = "user@conversa.com";
            $userData['us_password'] = md5($password);
            $userData['us_birthday'] = '2009-12-25';
            $userData['us_created'] = time();
            $conn->insert('co_user',$userData);
            
            $userData['us_name'] = "Usuario1";
            $userData['us_email'] = "user1@conversa.com";
            $userData['us_password'] = md5($password);
            $userData['us_birthday'] = '2004-12-25';
            $userData['us_created'] = time();
            $conn->insert('co_user',$userData);
            
            //738028800 mi cumple
            //684374400 faby cumple
            //629769600 daniel cumple
            //664675200 titi cumple
            //191203200 douglas cumple

            $businessData = array();
            $businessData['bu_founded'] = "2015-05-05";
            
            $businessData['bu_name'] = "Autos1";
            $businessData['bu_email'] = "business@conversa.com";
            $businessData['bu_conversa_id'] = \Conversa\Utils::generateConversaIdForBusiness("Autos1");
            $businessData['bu_password'] = md5($password);
            $businessData['bu_max_devices'] = 2;
            $businessData['bu_created'] = time();
            $businessData['bu_id_category'] = 1;
            $conn->insert('co_business',$businessData);
            
            $businessData['bu_name'] = "Autos2";
            $businessData['bu_email'] = "business1@conversa.com";
            $businessData['bu_conversa_id'] = \Conversa\Utils::generateConversaIdForBusiness("Autos2");
            $businessData['bu_password'] = md5($password);
            $businessData['bu_max_devices'] = 2;
            $businessData['bu_created'] = time();
            $businessData['bu_id_category'] = 1;
            $conn->insert('co_business',$businessData);
            
            $messageData = array();
            
            $messageData['mt_description'] = "Texto";
            $conn->insert('co_message_type',$messageData);
            $messageData['mt_description'] = "Imagen";
            $conn->insert('co_message_type',$messageData);
            $messageData['mt_description'] = "Ubicacion";
            $conn->insert('co_message_type',$messageData);
            
            $typeData = array();
            
            $typeData['ut_description'] = "Negocio";
            $conn->insert('co_user_type',$typeData);
            
            $typeData['ut_description'] = "Usuario";
            $conn->insert('co_user_type',$typeData);
            
            $statusData = array();
            $statusData['st_created'] = time();
            
            $statusData['st_status'] = "Online";
            $conn->insert('co_status',$statusData);
            $statusData['st_status'] = "Offline";
            $conn->insert('co_status',$statusData);
            $statusData['st_status'] = "Away";
            $conn->insert('co_status',$statusData);
            $statusData['st_status'] = "Invisible";
            $conn->insert('co_status',$statusData);
            
            $conn->commit();    
                
            return $app['twig']->render('installer/installerStep3.twig', array(
                'ROOT_URL' => $rootUrl,
                'LOCAL_ROOT_URL' => $localRootUrl,
                'ConnectionSucceed' => $connectionResult,
                'DbParams' => $connectionParams,
                'SupportUserId' => $conn->lastInsertId("_id"),
            ));     
            
        });
        
        return $controllers;
    }
    
}
