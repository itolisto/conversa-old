<?php

/*
 * This file is part of the Silex framework.
 *
 * Copyright (c) 2013 clover studio official account
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Conversa\Controller\Web\Admin;

use Silex\Application;
use Symfony\Component\HttpFoundation\Request;
use Conversa\Controller\Web\ConversaWebBaseController;

class EmoticonController extends ConversaWebBaseController
{

    
    public function connect(Application $app)
    {
        parent::connect($app);
        
        $controllers = $app['controllers_factory'];
        $self = $this;

        //
        // List/paging logics
        //

        $controllers->get('emoticon/list', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $count = $self->app['conversadb']->findEmoticonCount();
            
            $page = $request->get('page');
            if(empty($page))
                $page = 1;
            
            $msg = $request->get('msg');
            if(!empty($msg))
                $self->setInfoAlert($self->language[$msg]);
            
            $emoticons = $self->app['conversadb']->findAllEmoticonsWithPaging(ADMIN_LISTCOUNT,($page-1)*ADMIN_LISTCOUNT);
            
            // convert timestamp to date
            for($i = 0 ; $i < count($emoticons) ; $i++){
                $emoticons[$i]['created']  = date("Y.m.d",$emoticons[$i]['created']);
                $emoticons[$i]['modified'] = date("Y.m.d",$emoticons[$i]['modified']);
            }

            return $self->render('admin/emoticonList.twig', array(
                'emoticons' => $emoticons,
                'pager' => array(
                    'baseURL' => ROOT_URL . "/admin/emoticon/list?page=",
                    'pageCount' => ceil($count / ADMIN_LISTCOUNT) - 1,
                    'page' => $page,
                ),
            ));
                        
        })->before($app['adminBeforeTokenChecker']);

        $controllers->get('emoticon/add', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            return $self->render('admin/emoticonForm.twig', array(
                'mode' => 'new',
                'formValues' => $self->getEmptyFormData(),
            ));
                        
        })->before($app['adminBeforeTokenChecker']);        
        
        //
        // create new logics
        //
        $controllers->post('emoticon/add', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $formValues = $request->request->all();
            $validationError = false;
            $fileName = "";
            $thumbFileName = "";
            
            $validationResult = $self->validate($request);

            if($validationResult){
                
                if($request->files->has("file")){
                
                    $file = $request->files->get("file");
                    
                    if($file && $file->isValid()){
                    
                        $fileName = $self->savePicture($file,UTR_EMOTICON);
                    
                    }
                    
                }

                $result = $self->app['conversadb']->createEmoticon(
                    $formValues['identifier'],
                    $fileName
                );
                
                if($result == 1) {
                    return $app->redirect(ROOT_URL . '/admin/emoticon/list?msg=messageEmoticonAdded');
                } else {
                    return $app->redirect(ROOT_URL . '/admin/emoticon/list?msg=messageEmoticonError');
                }
            }
            
            return $self->render('admin/emoticonForm.twig', array(
                'mode' => 'new',
                'formValues' => $formValues
            ));
                        
        })->before($app['adminBeforeTokenChecker']);        
        
        //
        // Detail logics
        //
        $controllers->get('emoticon/view/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $emoticon = $self->app['conversadb']->findEmoticonById($id);

            return $self->render('admin/emoticonForm.twig', array(
                'mode' => 'view',
                'formValues' => $emoticon
            ));
            
        })->before($app['adminBeforeTokenChecker']);

        //
        // Edit logics
        //

        $controllers->get('emoticon/edit/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $emoticon = $self->app['conversadb']->findEmoticonById($id);
            
            return $self->render('admin/emoticonForm.twig', array(
                'id' => $id,
                'mode' => 'edit',
                'formValues' => $emoticon
            ));
            
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('emoticon/edit/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $validationError = false;
            $fileName = "";
            $emoticon = $self->app['conversadb']->findEmoticonById($id);
            $formValues = $request->request->all();

            $fileName = $emoticon['file_id'];
            
            $validationResult = $self->validate($request,true,$id);
            
            if($validationResult){

                if($request->files->has("file")){
                
                    $file = $request->files->get("file");
                    
                    if($file && $file->isValid()){
                    
                        $fileName = $self->savePicture($file,UTR_EMOTICON);
                    
                    }
                    
                }
                
                $result = $self->app['conversadb']->updateEmoticon(
                    $id,
                    $formValues['identifier'],
                    $fileName
                );
                
                if($result) {
                    return $app->redirect(ROOT_URL . '/admin/emoticon/list?msg=messageEmoticonChanged');
                } else {
                    return $app->redirect(ROOT_URL . '/admin/emoticon/list?msg=messageEmoticonChangedError');
                }
            }
    
            return $self->render('admin/emoticonForm.twig', array(
                'id' => $id,
                'mode' => 'edit',
                'formValues' => $emoticon
            ));
                        
        })->before($app['adminBeforeTokenChecker']);    
        
        //
        // Delete logics
        //
        $controllers->get('emoticon/delete/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $emoticon = $self->app['conversadb']->findEmoticonById($id);
            
            return $self->render('admin/emoticonDelete.twig', array(
                'id' => $id,
                'mode' => 'delete',
                'formValues' => $emoticon
            ));
            
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('emoticon/delete/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $formValues = $request->request->all();
            
            if(isset($formValues['submit_delete'])){
                $result = $self->app['conversadb']->deleteEmoticon($id);
                if($result) {
                    return $app->redirect(ROOT_URL . '/admin/emoticon/list?msg=messageEmoticonDeleted');
                } else {
                    return $app->redirect(ROOT_URL . '/admin/emoticon/list?msg=messageEmoticonDeletedError');
                }
            }else{
                return $app->redirect(ROOT_URL . '/admin/emoticon/list');
            }
            
        })->before($app['adminBeforeTokenChecker']);

    
        
        return $controllers;
    }
    
    public function validate($request,$editmode = false,$userId = ""){
        
        $formValues = $request->request->all();
        
        $validationResult = true;
        
        // required field check
        if(empty($formValues['identifier'])){
            $this->setErrorAlert($this->language['messageValidationErrorRequired']);
            $validationResult = false;
        }

        // format check
        if(!preg_match("/^[a-zA-Z0-9_-]+$/", $formValues['identifier'])){
              $this->setErrorAlert($this->language['formGroupEmoticonIdentifier'] . " " . $this->language['messageValidationErrorAlphaNumeric']);
              $validationResult = false;
        }

        if($request->files->has("file")){
        
            $file = $request->files->get("file");
            
            if($file && $file->isValid()){
            
                $mimeType = $file->getClientMimeType();
                
                if(!preg_match("/png/", $mimeType)){
                    $this->setErrorAlert($this->language['messageValidationErrorFormatPng']);
                    $validationResult = false;
                    
                }else{
                                        
                }
            
            }else{
                if(!$editmode){
                    $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                    $validationResult = false;
                }
            }
            
        }else{
            if(!$editmode){
                $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                $validationResult = false;
            }
        }
        

        return $validationResult;
        
    }
    
    public function getEmptyFormData(){
        return  array(
                    'identifier'=>'',
                );
    }
    
}
