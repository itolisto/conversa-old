<?php

/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Conversa\Controller;

use Silex\Application;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class FileController extends ConversaBaseController {

    static $paramRute = 'type';
    static $paramName = 'file';
    static $fileDirName = 'uploads';
        
    public function connect(Application $app) {

        $controllers = $app['controllers_factory'];
        $self = $this;
        
        $controllers->get('/filedownloader', function (Request $request) use ($app,$self) {
                
            try {
                $fileID     = $request->get(FileController::$paramName);
                $fileFolder = $request->get(FileController::$paramRute);
            } catch (InvalidArgumentException $e) {
                return $self->returnErrorResponse($e);
            }
            
            switch($fileFolder){
                case CONST_FOLDER_BUSINESS:
                    $folder = "/business/";
                    break;
                case CONST_FOLDER_USER:
                    $folder = "/user/";
                    break;
                case CONST_FOLDER_CATEGORY:
                    $folder = "/category/";
                    break;
                case CONST_FOLDER_EMOTICON:
                    $folder = "/emoticon/";
                    break;
                case CONST_FOLDER_IMAGES:
                    $folder = "/images/";
                    break;
                default:
                    $folder = "/";
                    break;
            }
            
            $fileIDs    = str_replace("?XDEBUG_SESSION_START=netbeans-xdebug", "", $fileID);
            $filePath = __DIR__.'/../../../'.FileController::$fileDirName.$folder.$fileIDs;//basename($fileIDs);
            
            $app['logger']->addDebug($filePath);
            
            if(file_exists($filePath) && is_file($filePath)) {
                $response = new Response();
                $lastModified = new \DateTime();
                $file = new \SplFileInfo($filePath);

                $lastModified = new \DateTime();
                $lastModified->setTimestamp($file->getMTime());
                $response->setLastModified($lastModified);

                if ($response->isNotModified($request)) {
                    $response->prepare($request)->send();
                    return $response;
                }

                $response = $app->sendFile($filePath);
                $currentDate = new \DateTime(null, new \DateTimeZone('UTC'));
                $response->setDate($currentDate)->prepare($request)->send();

                return $response; 
            } else {
                return $self->returnErrorResponse("File doesn't exists.");
            }
        });
        
        $controllers->post('/fileuploader', function (Request $request) use ($app,$self) {
            try {
                $file       = $request->files->get(FileController::$paramName);
                $fileFolder = $request->files->get(FileController::$paramRute);
            } catch (InvalidArgumentException $e) {
                return $self->returnErrorResponse($e);
            }
            
            switch($fileFolder){
                case CONST_FOLDER_BUSINESS:
                    $folder = "/business/";
                    break;
                case CONST_FOLDER_USER:
                    $folder = "/user/";
                    break;
                case CONST_FOLDER_CATEGORY:
                    $folder = "/category/";
                    break;
                case CONST_FOLDER_EMOTICON:
                    $folder = "/emoticon/";
                    break;
                case CONST_FOLDER_IMAGES:
                    $folder = "/images/";
                    break;
                default:
                    return $self->returnErrorResponse("No se ha podido subir el archivo! Prueba más tarde.");
            }
            
            $fileName = \Conversa\Utils::randString(FILES_TOKEN_LENGTH, FILES_TOKEN_LENGTH);
            $dir      = __DIR__ . '/../../../' . FileController::$fileDirName;

            if (!is_writable($dir)) {
                return $self->returnErrorResponse("No se ha podido subir el archivo! Prueba más tarde.");
            }

            $file->move($dir, $fileName); 
            return $fileName;
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        return $controllers;
    }
}