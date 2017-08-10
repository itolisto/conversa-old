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

class BusinessController extends ConversaWebBaseController {
    
    public function connect(Application $app) {
        $controllers = parent::connect($app);
        $self = $this;
        
        // List/paging logics
        $controllers->get('business/list', function (Request $request) use ($app,$self) {
            $self->setVariables();
            // search criteria
            $searchCriteriaBusinessName = $app['session']->get('businessCriteria');
            
            if (empty($searchCriteriaBusinessName)) {
                $searchCriteriaBusinessName = '';
            }
            
            $count = $self->app['conversadb']->findBusinessCountWithCriteria($searchCriteriaBusinessName);
            
            $page = $request->get('page');
            if (empty($page)) {
                $page = 1;
            }

            $msg = $request->get('msg');
            if (!empty($msg)) {
                $self->setInfoAlert($self->language[$msg]);
            }

            $business = $self->app['conversadb']->findAllBusinessWithPagingWithCriteria(($page-1)*ADMIN_LISTCOUNT,ADMIN_LISTCOUNT,$searchCriteriaBusinessName);
            
            // convert timestamp to date
            for($i = 0 ; $i < count($business) ; $i++){
                $business[$i]['created']  = date("d/m/Y",$business[$i]['created']);
            }
            
            return $self->render('admin/businessList.twig', array(
                'CONST_FOLDER_BUSINESS' => CONST_FOLDER_BUSINESS,
                'business' => $business,
                'pager' => array(
                    'baseURL' => ROOT_URL . "/admin/business/list?page=",
                    'pageCount' => ceil($count / ADMIN_LISTCOUNT) - 1,
                    'page' => $page,
                ),
                'searchCriteria' => array(
                    'businessName' => $searchCriteriaBusinessName
                )
            ));               
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('business/list', function (Request $request) use ($app,$self) {
            
            $businessCriteria = trim($request->get('search-businessName'));
            $clearButton = $request->get('clear');
            
            if(!empty($clearButton)){
                $app['session']->set('businessCriteria', '');
            } else {
                $app['session']->set('businessCriteria', $businessCriteria);
            }
            
            return $app->redirect(ROOT_URL . '/admin/business/list');           
        })->before($app['adminBeforeTokenChecker']);

        
        /**************************************************/
        
        $controllers->get('business/add', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/business/list?msg=messageNoPermission');
            }
            
            $categories = $self->app['conversadb']->getAllCategoryName();
            $countries  = $self->app['conversadb']->getAllCountries();
            $plans      = $self->app['conversadb']->getAllPlans();
            
            return $self->render('admin/businessAdd.twig', array(
                'mode'          => 'new',
                'categoryList'  => $categories,
                'countriesList' => $countries,
                'planList'      => $plans,
                'formValues'    => $self->getEmptyFormData(),
            ));
        })->before($app['adminBeforeTokenChecker']);
        
        $controllers->post('business/add', function (Request $request) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission()) {
                return $app->redirect(ROOT_URL . '/admin/business/list?msg=messageNoPermission');
            }

            $formValues       = $request->request->all();
            $validationResult = $self->validate($request);

            if($validationResult) {
                
                $file          = $request->files->get("file");
                $fileName      = $self->savePicture($file,UTR_BUSINESS);
                $thumbFileName = $self->saveThumb($fileName,$file,UTR_BUSINESS);

                $result = $self->app['conversadb']->createBusiness(
                    $formValues['name'],
                    $formValues['email'],
                    md5($formValues['password']),
                    $formValues['about'],
                    $formValues['founded'],
                    $formValues['expiration'],
                    $fileName,
                    $thumbFileName,
                    $formValues['max_devices_count'],
                    $formValues['country'],
                    $formValues['id_category'],
                    $formValues['plan']
                );
                
                if($result) {
                    return $app->redirect(ROOT_URL . '/admin/business/list?msg=messageBusinessAdded');
                } else {
                    $this->setErrorAlert($this->language['messageBusinessAddedError']);
                }
            }
            
            $categories = $self->app['conversadb']->getAllCategoryName();
            $countries  = $self->app['conversadb']->getAllCountries();
            $plans      = $self->app['conversadb']->getAllPlans();
            
            return $self->render('admin/businessAdd.twig', array(
                'mode'          => 'new',
                'categoryList'  => $categories,
                'countriesList' => $countries,
                'planList'      => $plans,
                'formValues'    => $formValues,
            ));
        })->before($app['adminBeforeTokenChecker']);
        
        /**************************************************/

        $controllers->get('business/edit/{id}', function (Request $request,$id) use ($app,$self) {
            $tab = 'profile';
            $self->setVariables();
            
            if(!$self->checkPermission() && $self->loginedUser['_id'] != $id) {
                return $app->redirect(ROOT_URL . '/admin/business/list?msg=messageNoPermission');
            }            
            
            $action = $request->get('action');
            
            if($action == 'removeContact') {
                $removeUserId = $request->get('value');
                if(!empty($removeUserId)){
                    $self->app['conversadb']->removeContact($id,$removeUserId);
                    $self->setInfoAlert($self->language['messageRemoveContact']);
                }
                $self->updateLoginUserData();
                $tab = 'contacts';
            }

            $user       = $self->app['conversadb']->findBusinessById($id,false,true);
            $categories = $self->app['conversadb']->getAllCategoryName();
            $countries  = $self->app['conversadb']->getAllCountries();
            $plans      = $self->app['conversadb']->getAllPlans();
            
            return $self->render('admin/businessEdit.twig', array(
                'id'            => $id,
                'mode'          => 'edit',
                'categoryList'  => $categories,
                'countriesList' => $countries,
                'planList'      => $plans,
                'formValues'    => $user,
                'categoryList'  => $categories,
                'tab'           => $tab,
                'contacts'      => array(),
                'CONST_FOLDER_BUSINESS' => CONST_FOLDER_BUSINESS
            ));
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('business/edit/{id}', function (Request $request,$id) use ($app,$self) {
            
            $self->setVariables();

            if(!$self->checkPermission() && $self->loginedUser['_id'] != $id){
                return $app->redirect(ROOT_URL . '/admin/business/list?msg=messageNoPermission');
            }
            
            $user       = $self->app['conversadb']->findBusinessById($id,false,false);
            $formValues = $request->request->all();

            $fileName       = $user['avatar_file_id'];
            $thumbFileName  = $user['avatar_thumb_file_id'];
            
            $validationResult = $self->validate($request,$id,true);
            
            if($validationResult) {
                
                if($request->files->has("file")) {
                    $file = $request->files->get("file");
                    if(!empty($file)) {
                        $self->deleteOldPictures($fileName,$thumbFileName, BUSINESS_TYPE);
                        $fileName      = $self->savePicture($file,UTR_BUSINESS);
                        $thumbFileName = $self->saveThumb($fileName,$file,UTR_BUSINESS);
                    }
                }
                
                $password = $user['password'];
                
                if(isset($formValues['chkbox_change_password'])){
                    $password = md5($formValues['password']);
                }
                
                $result = $self->app['conversadb']->updateBusiness(
                    $id,
                    array(
                        'name'                  => $formValues['name'],
                        'email'                 => $formValues['email'],
                        'password'              => $password,
                        'about'                 => $formValues['about'],
                        'founded'               => $formValues['founded'],
                        'expiration'            => $formValues['expiration'],
                        'max_devices'           => $formValues['max_devices_count'],
                        'country'               => $formValues['country'],
                        'plan'                  => $formValues['plan'],
                        'id_category'           => $formValues['id_category'],
                        'avatar_file_id'        => $fileName,
                        'avatar_thumb_file_id'  => $thumbFileName
                    ),
                    false
                );
                
                if(!is_null($result)) {
                    $user = $self->app['conversadb']->findBusinessById($id,false,false);
                    $self->setInfoAlert($self->language['messageBusinessChanged']);
                } else {
                    $self->setErrorAlert($this->language['messageBusinessChangedError']);
                }
            }

            $categories = $self->app['conversadb']->getAllCategoryName();
            $countries  = $self->app['conversadb']->getAllCountries();
            $plans      = $self->app['conversadb']->getAllPlans();
            
            return $self->render('admin/businessEdit.twig', array(
                'id'            => $id,
                'mode'          => 'edit',
                'categoryList'  => $categories,
                'countriesList' => $countries,
                'planList'      => $plans,
                'formValues'    => $user,
                'categoryList'  => $categories,
                'tab'           => 'profile',
                'contacts'      => array(),
                'CONST_FOLDER_BUSINESS' => CONST_FOLDER_BUSINESS
            ));
        })->before($app['adminBeforeTokenChecker']);    
        
        /**************************************************/
        
        $controllers->get('business/delete/{id}', function (Request $request,$id) use ($app,$self) {
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/business/list?msg=messageNoPermission');
            }
            
            return $self->render('admin/businessDelete.twig', array(
                'id' => $id,
                'mode' => 'delete'
            ));
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('business/delete/{id}', function (Request $request,$id) use ($app,$self) {
            $self->setVariables();
            
            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/business/list?msg=messageNoPermission');
            }

            $formValues = $request->request->all();
            
            if(isset($formValues['submit_delete'])){
                $result = $self->app['conversadb']->deleteBusiness($id);
                if($result) {
                    return $app->redirect(ROOT_URL . '/admin/business/list?msg=messageBusinessDeleted');
                } else {
                    return $app->redirect(ROOT_URL . '/admin/business/list?msg=messageBusinessDeletedError');
                }
            }
            
            return $app->redirect(ROOT_URL . '/admin/business/list');
        })->before($app['adminBeforeTokenChecker']);
        
        /**************************************************/
    
        $controllers->get('business/conversation/{userId}', function (Request $request,$userId) use ($app,$self) {
            
            $self->setVariables();
            
            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $count = $self->app['conversadb']->getConversationHistoryCount($userId);
            
            $page = $request->get('page');
            if(empty($page))
                $page = 1;
            
            $msg = $request->get('msg');
            if(!empty($msg))
                $self->setInfoAlert($self->language[$msg]);
            
            $conversationHistory = $self->app['conversadb']->getConversationHistory($userId,($page-1)*ADMIN_LISTCOUNT,ADMIN_LISTCOUNT);
            
            // convert timestamp to date
            for($i = 0 ; $i < count($conversationHistory) ; $i++){
                $conversationHistory[$i]['created'] = date("Y.m.d H:i:s",$conversationHistory[$i]['created']);
            }

            $user = $self->app['conversadb']->findBusinessById($userId,false,false);
            
            return $self->render('admin/userConversationHistory.twig', array(
                'conversations' => $conversationHistory,
                'pager' => array(
                    'baseURL'   => ROOT_URL . "/admin/user/conversateion/{$userId}?page=",
                    'pageCount' => ceil($count / ADMIN_LISTCOUNT) - 1,
                    'page'      => $page,
                ),
                'user' => $user
            ));
            
        })->before($app['adminBeforeTokenChecker']);
        
        return $controllers;
    }
    
    public function validate($request,$id = 0,$editmode = false){
        
        $formValues = $request->request->all();
        //'name','email','password','about','founded','expiration','max_devices_count','country','plan','id_category'
        if( empty($formValues['name'])    || empty($formValues['email'])      || empty($formValues['about']) ||
            empty($formValues['founded']) || empty($formValues['expiration']) || empty($formValues['max_devices_count']) ||
            empty($formValues['country']) || empty($formValues['plan'])       || empty($formValues['id_category']) ){
            $this->setErrorAlert($this->language['messageValidationErrorRequired']);
            return false;
        }
        
        if($editmode) {
            if(isset($formValues['chkbox_change_password'])) {
                if(empty($formValues['password'])) {
                    $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                    return false;
                }
            }
        } else {
            if(empty($formValues['password'])) {
                $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                return false;
            }
        }

        // numeric
        if( !is_numeric($formValues['max_devices_count']) || !is_numeric($formValues['id_category']) ||
            !is_numeric($formValues['plan'])              || !is_numeric($formValues['country'])     ){
            $this->setErrorAlert($this->language['formMaxDevices'] . " or ". $this->language['formBusinessCategory'] . " " . $this->language['messageValidationErrorNumeric']);
            return false;
        }
        
        if(!\Conversa\Utils::validateDate($formValues['founded'], 'Y-m-d') || !\Conversa\Utils::validateDate($formValues['expiration'], 'Y-m-d')) {
            $this->setErrorAlert($this->language['messageValidationErrorDate']);
            return false;
        }

        if($editmode) {
            // check name is unique
            $check = $this->app['conversadb']->findBusinessByEmailOrName($formValues['name'],1);
            if($check != $id) {
                $this->setErrorAlert($this->language['messageValidationErrorBusinessNameNotUnique']);
                return false;
            }

            // check email is unique
            $check = $this->app['conversadb']->findBusinessByEmailOrName($formValues['email'],2);
            if($check != $id) {
                $this->setErrorAlert($this->language['messageValidationErrorBusinessEmailNotUnique']);
                return false;
            }
        } else {
            // check name is unique
            $check = $this->app['conversadb']->findBusinessByEmailOrName($formValues['name'],1);
            if($check != 0) {
                $this->setErrorAlert($this->language['messageValidationErrorBusinessNameNotUnique']);
                return false;
            }

            // check email is unique
            $check = $this->app['conversadb']->findBusinessByEmailOrName($formValues['email'],2);
            if($check != 0) {
                $this->setErrorAlert($this->language['messageValidationErrorBusinessEmailNotUnique']);
                return false;
            }
        }

        if(!$editmode) {
            if(!$request->files->has("file")) {
                $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                return false;
            } else {
                $file = $request->files->get("file");
                if(empty($file)) {
                    $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                    return false;
                }
            }
        }
        
        return true;
    }
    
    public function getEmptyFormData(){
        return  array(
            'name'              =>'',
            'email'             =>'',
            'password'          =>'',
            'about'             =>'',
            'founded'           => '',
            'expiration'        => '',
            'max_devices_count' => 3,
            'country'           => '',
            'plan'              => 0,
            'id_category'       => 0
        );   
    }
    
}
