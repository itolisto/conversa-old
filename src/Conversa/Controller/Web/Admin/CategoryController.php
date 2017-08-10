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

class CategoryController extends ConversaWebBaseController
{

    
    public function connect(Application $app)
    {
        $controllers = parent::connect($app);
        $self = $this;

        //
        // List/paging logics
        //

        $controllers->get('category/list', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/category/list?msg=messageNoPermission');
            }

            $count = $self->app['conversadb']->findCategoryCount();
            
            $page = $request->get('page');
            if (empty($page)) {
                $page = 1;
            }

            $msg = $request->get('msg');
            if (!empty($msg)) {
                $self->setInfoAlert($self->language[$msg]);
            }

            $categories = $self->app['conversadb']->findAllCategoryWithPaging(ADMIN_LISTCOUNT,($page-1)*ADMIN_LISTCOUNT);
            
            // convert timestamp to date
            for($i = 0 ; $i < count($categories['rows']) ; $i++){
                $categories['rows'][$i]['value']['created'] = date("Y.m.d",$categories['rows'][$i]['value']['created']);
                $categories['rows'][$i]['value']['modified'] = date("Y.m.d",$categories['rows'][$i]['value']['modified']);
            }

            return $self->render('admin/categoryList.twig', array(
                'categories' => $categories['rows'],
                'pager' => array(
                    'baseURL' => ROOT_URL . "/admin/category/list?page=",
                    'pageCount' => ceil($count / ADMIN_LISTCOUNT) - 1,
                    'page' => $page,
                ),
            ));
        })->before($app['adminBeforeTokenChecker']);
        
        /**************************************************/

        $controllers->get('category/add', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            return $self->render('admin/categoryForm.twig', array(
                'mode' => 'new',
                'formValues' => $self->getEmptyFormData(),
            ));
                        
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('category/add', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/category/list?msg=messageNoPermission');
            }

            $formValues = $request->request->all();
            $fileName = "";
            
            $validationResult = $self->validate($request);

            if($validationResult){
                if($request->files->has("file")){
                    $file = $request->files->get("file");
                    if($file && $file->isValid()){
                        $fileName = $self->savePicture($file,UTR_CATEGORY);
                    }
                }
                    
                $self->app['conversadb']->createCategory(
                    $formValues['title'],
                    $fileName
                );
                
                return $app->redirect(ROOT_URL . '/admin/category/list?msg=messageCategoryAdded');
            }
            
            return $self->render('admin/categoryForm.twig', array(
                'mode' => 'new',
                'formValues' => $formValues
            ));       
        })->before($app['adminBeforeTokenChecker']);

        /**************************************************/

        $controllers->get('category/edit/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/category/list?msg=messageNoPermission');
            }

            $category = $self->app['conversadb']->findCategoryById($id,false);
            
            return $self->render('admin/categoryForm.twig', array(
                'id' => $id,
                'mode' => 'edit',
                'formValues' => $category
            ));
            
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('category/edit/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/category/list?msg=messageNoPermission');
            }

            $fileName = "";
            $category = $self->app['conversadb']->findCategoryById($id,false);
            $formValues = $request->request->all();

            $fileName = $category['avatar_file_id'];
            
            $validationResult = $self->validate($request,true,$id);
            
            if($validationResult){

                if($request->files->has("file")){
                    $file = $request->files->get("file");
                    
                    if($file && $file->isValid()){
                        $fileName = $self->savePicture($file,UTR_CATEGORY);
                    }
                }
                
                $self->app['conversadb']->updateCategory(
                    $id,
                    $formValues['title'],
                    $fileName
                );
                
                return $app->redirect(ROOT_URL . '/admin/category/list?msg=messageCategoryChanged');

            }
    
            return $self->render('admin/categoryForm.twig', array(
                'id' => $id,
                'mode' => 'edit',
                'formValues' => $category
            ));       
        })->before($app['adminBeforeTokenChecker']);    
        
        /**************************************************/
        
        $controllers->get('category/delete/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/category/list?msg=messageNoPermission');
            }

            $category = $self->app['conversadb']->findCategoryById($id,false);
            
            return $self->render('admin/categoryDelete.twig', array(
                'id' => $id,
                'mode' => 'delete',
                'formValues' => $category
            ));
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('category/delete/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/category/list?msg=messageNoPermission');
            }

            $formValues = $request->request->all();
            
            if(isset($formValues['submit_delete'])){
                $self->app['conversadb']->deleteCategory($id);
                return $app->redirect(ROOT_URL . '/admin/category/list?msg=messageCategoryDeleted');
            }else{
                return $app->redirect(ROOT_URL . '/admin/category/list');
            }
        })->before($app['adminBeforeTokenChecker']);

        return $controllers;
    }
    
    public function validate($request,$editmode = false,$userId = ""){
        
        $formValues = $request->request->all();
        
        if(empty($formValues['title'])){
            $this->setErrorAlert($this->language['messageValidationErrorRequired']);
            return false;
        }
        
        // check name is unique
        $check = $this->app['conversadb']->findCategoryByName($formValues['title']);
        if(isset($check['_id'])){
            $this->setErrorAlert($this->language['messageValidationErrorCategoryNotUnique']);
            return false;
        }

        if(!$editmode){
            if(!$request->files->has("file")){
                $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                return false;
            }else{
                $file = $request->files->get("file");
                if(empty($file)){
                    $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                    return false;
                }
            }
        }
        
        return true;
    }
    
    public function getEmptyFormData(){
        return  array(
                    'title'=>'',
                );
    }
    
}
