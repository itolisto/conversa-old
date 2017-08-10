<?php

/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Conversa\Controller\Web;

use Silex\Application;
use Silex\ControllerProviderInterface;
use Conversa\Controller\FileController;
use Imagine\Gd\Imagine;
use Imagine\Image\Box;
use Imagine\Image\Palette\RGB;

class ConversaWebBaseController implements ControllerProviderInterface {
    
    var $language = array();
    var $messages = array();
    var $loginedUser = null;
    
    /**
     * Carga el archivo de idioma para utilizar en las vistas
     * con la variable 'lang'
     */
    public function __construct() {
        $currentLanguage = "en";
        
        if(defined("DEFAULT_LANGUAGE")){
            $currentLanguage = DEFAULT_LANGUAGE;
        }
        
        $languageFile = __DIR__."/../../../../config/i18n/{$currentLanguage}.ini";
        $this->language = parse_ini_file($languageFile);
    }
    
    /**
     * Devuelve una nueva instancia de 'ControllerCollection'
     * 
     * @param Application $app
     * @return Application
     */
    public function connect(Application $app) {
        $this->app = $app;
        $controllers = $app['controllers_factory'];
        return $controllers;        
    }
    
    /**
     * Verifica si hay guardada una sesion iniciada
     * 
     * @return boolean
     */
    public function checkLogin(){
        if ($this->app['session']->get('user') == null) {
            return false;
        } else {
            return true;
        }
    }
    
    /**
     * Guarda la sesion para el usuario que ingreso
     */
    public function setVariables(){
        $this->loginedUser = $this->app['session']->get('user');
    }
    
    /**
     * Actualiza informacion para el usuario con
     * la sesion activa
     */
    public function updateLoginUserData(){
        $user = $this->app['conversadb']->findUserById($this->loginedUser['_id'],false);
        $this->app['session']->set('user',$user);
        $this->loginedUser = $this->app['session']->get('user');
    }
    
    /**
     * 
     * 
     * @param type $userId
     * @return boolean
     */
    public function checkUserIsInLoginUserContact($userId){
        $contacts = $this->loginedUser['contacts'];
        $isExists = false;
        
        foreach($contacts as $contactUserId){
            if (intval($userId) == intval($contactUserId)) {
                $isExists = true;
            }
        }
        
        return $isExists;
    }
    
    /**
     * Renderiza la vista y envia los parametro indicados
     * 
     * @param type $templateFile
     * @param type $params
     * @return type
     */
    public function render($templateFile,$params){
        $user = $this->app['session']->get('user');
        $params['loginedUser'] = $user;
        $params['isAdmin']     = $user['_id'] == 1;
        $params['lang']        = $this->language;
        $params['ROOT_URL']    = ROOT_URL;
        
        if (isset($this->messages['info'])) {
            $params['infoMessage'] = $this->messages['info'];
        }

        if (isset($this->messages['error'])) {
            $params['errorMessage'] = $this->messages['error'];
        }

        return $this->app['twig']->render($templateFile,$params);
    }
    
    /**
     * Define un mensaje de información que se utiliza
     * en algunas vistas
     * 
     * @param type $message
     */
    public function setInfoAlert($message){
        $this->messages['info'] = $message;
    }
    
    /**
     * Define un mensaje de error que se utiliza
     * en algunas vistas
     * 
     * @param type $message
     */
    public function setErrorAlert($message){
        $this->messages['error'] = $message;
    }
    
    /**
     * 
     * @param type $file
     * @return string
     */
    public function savePicture($file,$toFolder) {        
        $uploadDirPath = __DIR__.'/../../../../' . FileController::$fileDirName;
        switch ($toFolder) {
            case UTR_BUSINESS:
                $folder = '/business/';
                break;
            case UTR_USER:
                $folder = '/user/';
                break;
            case UTR_EMOTICON:
                $folder = '/emoticon/';
                break;
            case UTR_CATEGORY:
                $folder = '/category/';
                break;
            default:
                $folder = '/images/';
                break;
        }
        
        $uploadDirPath .= $folder;
        $fileName = \Conversa\Utils::randString(FILES_TOKEN_LENGTH, FILES_TOKEN_LENGTH);

        // resize and save file
        $imagine = new Imagine();
        $palette = new RGB();
        $box     = new Box(480, 480);
        $palette->color('#000', 100);
        
        try {
            $image = $imagine->open($file->getPathname())->usePalette($palette);
            $image->resize($box)
                  ->usePalette($palette)
                  ->save($uploadDirPath.$fileName,array('format'=>'png','png_compression_level' => 9));
            
            $this->app['monolog']->addInfo("File added: ".$fileName." to ".$folder);
            
            return $fileName;
        } catch (\Exception $e) {
            $this->app['monolog']->addError("Creating file: ".$fileName." failed to folder ".$folder);
            return '';
        }
    }
    
    /**
     * 
     * @param type $file
     * @return string
     */
    public function saveThumb($tempfileName,$file,$toFolder) {
        if(empty($tempfileName)){
            return '';
        }
        
        $uploadDirPath = __DIR__.'/../../../../' . FileController::$fileDirName;
        switch ($toFolder) {
            case UTR_BUSINESS:
                $folder = '/business/';
                break;
            case UTR_USER:
                $folder = '/user/';
                break;
            default:
                $folder = '/images/';
                break;
        }
        
        $uploadDirPath .= $folder;
        
        if(strlen($tempfileName) >= THUMB_FILES_TOKEN_LENGTH) {
            $tempfileName = substr($tempfileName, 0, THUMB_FILES_TOKEN_LENGTH);
        }
        
        $fileName  = 'thumb_';
        $fileName .= $tempfileName;

        // resize and save file
        $imagine = new Imagine();
        $palette = new RGB();
        $box     = new Box(120, 120);
        $palette->color('#000', 100);
        
        try {
            $image     = $imagine->open($file->getPathname())->usePalette($palette);            
            $thumbnail = $image->thumbnail($box);
            $thumbnail->save($uploadDirPath.$fileName,array('format'=>'png','png_compression_level' => 2));
            
            $this->app['monolog']->addInfo("File added: ".$fileName." to ".$folder);
            
            return $fileName;
        } catch (\Exception $e) {
            $this->app['monolog']->addError("Creating file: ".$fileName." failed to folder ".$folder);
            return '';
        }
    }
    
    public function deleteOldPictures($file,$filethumb,$type = USER_TYPE) {
        $uploadDirPath = __DIR__.'/../../../../' . FileController::$fileDirName;
        $avatar = ''; $thumb = '';
        
        switch ($type) {
            case BUSINESS_TYPE:
                $folder = '/business/';
                break;
            case USER_TYPE:
                $folder = '/user/';
                break;
            default:
                $folder = '/';
                break;
        }
        
        $avatar = $uploadDirPath.$folder.$file;
        $thumb  = $uploadDirPath.$folder.$filethumb;
        // test to see if threading is available
        if(file_exists($avatar) && is_file($avatar)) {
            unlink($avatar);
            $this->app['monolog']->addInfo("File deleted: ".$avatar." from ".$folder);
        }

        if(file_exists($thumb) && is_file($thumb)) {
            unlink($thumb);
            $this->app['monolog']->addInfo("File deleted: ".$thumb." from ".$folder);
        }
    }
    
    /**
     * The source is found in http://softontherocks.blogspot.com/2014/09/eliminar-un-directorio-completo-con-php.html
     * 
     * @param type $dir
     * @return type
     */
    public function deleteDirectory($dir) {
        $result = false;
        if ($handle = opendir("$dir")){
            $result = true;
            while ((($file=readdir($handle))!==false) && ($result)){
                if ($file!='.' && $file!='..'){
                    if (is_dir("$dir/$file")){
                        $result = deleteDirectory("$dir/$file");
                    } else {
                        $result = unlink("$dir/$file");
                    }
                }
            }
            closedir($handle);
            if ($result) {
                $result = rmdir($dir);
            }
        }
        return $result;
    }
    
    /**
     * 
     * @return type
     */
    public function checkPermission(){
        return $this->loginedUser['_id'] == SUPPORT_USER_ID;
    }
            
}