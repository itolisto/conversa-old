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

class UserController extends ConversaWebBaseController {

    var $userStatusList = array(
        '1' => 'online',
        '2' => 'away',
        '3' => 'busy',
        '4' => 'offline',   
    );
    
    var $userGenderList = array(
        '0' => '',
        '1' => 'male',
        '2' => 'female',
    );
    
    public function connect(Application $app) {
        $controllers = parent::connect($app);
        $self = $this;
        
        // List/paging logics
        $controllers->get('user/list', function (Request $request) use ($app,$self) {
            $self->setVariables();
            // search criteria
            $searchCriteriaUserName = $app['session']->get('usernameCriteria');
            $criteria = "";
            $criteriaValues = array();
            
            if(!empty($searchCriteriaUserName)) {
                $criteria .= " and LOWER(name) like LOWER(?)";
                $criteriaValues[] = "%{$searchCriteriaUserName}%";
            }
            
            $count = $self->app['conversadb']->findUserCountWithCriteria($criteria,$criteriaValues);
            
            $page = $request->get('page');
            if (empty($page)) {
                $page = 1;
            }

            $msg = $request->get('msg');
            if (!empty($msg)) {
                $self->setInfoAlert($self->language[$msg]);
            }

            $users = $self->app['conversadb']->findAllUsersWithPagingWithCriteria(($page-1)*ADMIN_LISTCOUNT,ADMIN_LISTCOUNT,$criteria,$criteriaValues);
            
            // convert timestamp to date
            for($i = 0 ; $i < count($users['rows']) ; $i++) {
                $users['rows'][$i]['value']['created']  = date("Y.m.d",$users['rows'][$i]['value']['created']);
                $users['rows'][$i]['value']['modified'] = date("Y.m.d",$users['rows'][$i]['value']['modified']);
            }
            
            return $self->render('admin/userList.twig', array(
                'categoryList' => $self->getGroupCategoryList(),
                'users' => $users['rows'],
                'pager' => array(
                    'baseURL'   => ROOT_URL . "/admin/user/list?page=",
                    'pageCount' => ceil($count / ADMIN_LISTCOUNT) - 1,
                    'page'      => $page,
                ),
                'searchCriteria' => array(
                    'username'   => $searchCriteriaUserName
                )
            ));
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('user/list', function (Request $request) use ($app,$self) {
            $usernameCriteria = trim($request->get('search-username'));
            $clearButton      = $request->get('clear');
            
            if(!empty($clearButton)) {
                $app['session']->set('usernameCriteria', '');
            } else {
                $app['session']->set('usernameCriteria', $usernameCriteria);
            }
            
            return $app->redirect(ROOT_URL . '/admin/user/list'); 
        })->before($app['adminBeforeTokenChecker']);

        $controllers->get('user/add', function (Request $request) use ($app,$self) {
            $self->setVariables();

            if(!$self->checkPermission()) {
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }
            
            return $self->render('admin/userAdd.twig', array(
                'mode' => 'new',
                'statusList' => $self->userStatusList,
                'genderList' => $self->userGenderList,
                'formValues' => $self->getEmptyFormData(),
            ));
        })->before($app['adminBeforeTokenChecker']);
        
        //
        // create new logics
        //
        $controllers->post('user/add', function (Request $request) use ($app,$self) {
            $self->setVariables();

            if(!$self->checkPermission()) {
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $formValues     = $request->request->all();
            $fileName       = "";
            $thumbFileName  = "";
            $validationResult = $self->validate($request);

            if($validationResult){
                if($request->files->has("file")){
                    $file = $request->files->get("file");
                    
                    if($file && $file->isValid()){
                        $fileName = $self->savePicture($file,UTR_USER);
                        $thumbFileName = $self->saveThumb($fileName,$file,UTR_USER);
                    }
                }
                    
                $result = $self->app['conversadb']->createUser(
                    $formValues['name'],
                    $formValues['email'],
                    md5($formValues['password']),
                    strtotime($formValues['birthday']),
                    $formValues['gender'],
                    $formValues['about'],
                    $formValues['online_status'],
                    $formValues['max_contact_count'],
                    $fileName,
                    $thumbFileName
                );
                
                if($result == 1) {
                    return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageUserAdded');
                } else {
                    return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageUserAddedError');
                }
            }
            
            return $self->render('admin/userAdd.twig', array(
                'mode' => 'new',
                'statusList' => $self->userStatusList,
                'genderList' => $self->userGenderList,
                'formValues' => $formValues
            ));           
        })->before($app['adminBeforeTokenChecker']);        
        
        //
        // Detail logics
        //
        $controllers->get('user/view/{id}', function (Request $request,$id) use ($app,$self) {
            $self->setVariables();
            
            $user   = $self->app['conversadb']->findUserById($id,false);
            $action = $request->get('action');
                        
            if($action == 'addToContact') {
                $self->app['conversadb']->addContact($self->loginedUser['_id'],$user['_id']);
                $self->setInfoAlert($self->language['labelAddToContact']);
                $self->updateLoginUserData();
            }
            
            if($action == 'removeFromContact') {
                $self->app['conversadb']->removeContact($self->loginedUser['_id'],$user['_id']);
                $self->setInfoAlert($self->language['messageRemoveContact']);
                $self->updateLoginUserData();
            }
            
            $isInMyContact = $self->checkUserIsInLoginUserContact($user['_id']);
            $contact   = $self->app['conversadb']->getContactsByUserId($id);
            $contacted = $self->app['conversadb']->getContactedByUserId($id);
            
            return $self->render('admin/userProfile.twig', array(
                'mode'            => 'view',
                'statusList'      => $self->userStatusList,
                'genderList'      => $self->userGenderList,
                'userId'          => $id,
                'formValues'      => $user,
                'contacts'        => $contact,
                'contacted'       => $contacted,
                'groups'          => $group,
                'categoryList'    => $self->getGroupCategoryList(),
                'isInMyContact'   => $isInMyContact
            ));
        })->before($app['adminBeforeTokenChecker']);

        //
        // Edit logics
        //

        $controllers->get('user/edit/{id}', function (Request $request,$id) use ($app,$self) {
            $tab = 'profile';
            
            $self->setVariables();
            
            if(!$self->checkPermission() && $self->loginedUser['_id'] != $id) {
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }            
            
            $action = $request->get('action');
            
            if($action == 'removeContact'){
                $removeUserId = $request->get('value');
                if(!empty($removeUserId)){
                    $self->app['conversadb']->removeContact($id,$removeUserId);
                    $self->setInfoAlert($self->language['messageRemoveContact']);
                }
                $self->updateLoginUserData();
                
                $tab = 'contacts';
            }
              
            if($action == 'removeGroup'){
                $groupId = $request->get('value');
                if(!empty($groupId)){
                    $self->app['conversadb']->unSubscribeGroup($groupId,$id);
                    $self->setInfoAlert($self->language['messagUnsubscribed']);
                }
                $self->updateLoginUserData();
                
                $tab = 'groups';
            }

            $user = $self->app['conversadb']->findUserById($id,false);
            $user['birthday'] = date('Y-m-d',$user['birthday']);
            
            $contact = $self->app['conversadb']->getContactsByUserId($id);

            return $self->render('admin/userEdit.twig', array(
                'id' => $id,
                'mode' => 'edit',
                'statusList' => $self->userStatusList,
                'genderList' => $self->userGenderList,
                'contacts' => $contact,
                'groups' => $group,
                'formValues' => $user,
                'userId' => $id,
                'contacts' => $contact,
                'groups' => $group,
                'tab' => $tab,
            ));
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('user/edit/{id}', function (Request $request,$id) use ($app,$self) {
            $self->setVariables();

            if(!$self->checkPermission() && $self->loginedUser['_id'] != $id){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $fileName = "";
            $thumbFileName = "";
            $user = $self->app['conversadb']->findUserById($id,false);
            $formValues = $request->request->all();

            $fileName       = $user['avatar_file_id'];
            $thumbFileName  = $user['avatar_thumb_file_id'];
            
            $validationResult = $self->validate($request,true,$id);
            
            if($validationResult){

                if($request->files->has("file")){
                
                    $file = $request->files->get("file");
                    
                    if($file && $file->isValid()){
                    
                        $fileName = $self->savePicture($file,UTR_USER);
                        $thumbFileName = $self->saveThumb($fileName,$file,UTR_USER);
                    
                    }
                    
                }

                if(isset($formValues['chkbox_delete_picture'])){
                    $fileName = '';
                    $thumbFileName = '';
                }
                
                $password = $user['password'];
                
                if(isset($formValues['chkbox_change_password'])){
                    if(!empty($formValues['password'])) {
                        $password = md5($formValues['password']);
                    }
                }
                
                $self->app['conversadb']->updateUser(
                    $id,
                    array(
                        'name'                  => $formValues['name'],
                        'email'                 => $formValues['email'],
                        'password'              => $password,
                        'about'                 => $formValues['about'],
                        'online_status'         => $formValues['online_status'],
                        'birthday'              => strtotime($formValues['birthday']),
                        'gender'                => $formValues['gender'],
                        'avatar_file_id'        => $fileName,
                        'avatar_thumb_file_id'  => $thumbFileName,
                        'max_contact_count'     => $formValues['max_contact_count']
                    ),
                    false // Allow to change password and email
                );
                
                $user = $self->app['conversadb']->findUserById($id,false);
                $self->setInfoAlert($self->language['messageUserChanged']);
            }
    
            $contact = $self->app['conversadb']->getContactsByUserId($id);
            $user['birthday'] = date('Y-m-d',$user['birthday']);

            return $self->render('admin/userEdit.twig', array(
                'id' => $id,
                'mode' => 'edit',
                'statusList' => $self->userStatusList,
                'genderList' => $self->userGenderList,
                'userId' => $id,
                'contacts' => $contact,
                'groups' => $group,
                'formValues' => $user,
                'tab' => 'profile',
            ));       
        })->before($app['adminBeforeTokenChecker']);    
        
        //
        // Delete logics
        //
        $controllers->get('user/delete/{id}', function (Request $request,$id) use ($app,$self) {
            $self->setVariables();

            if(!$self->checkPermission()){
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $user = $self->app['conversadb']->findUserById($id,false);
            
            return $self->render('admin/userDelete.twig', array(
                'id'         => $id,
                'mode'       => 'delete',
                'formValues' => $user
            ));
        })->before($app['adminBeforeTokenChecker']);

        $controllers->post('user/delete/{id}', function (Request $request,$id) use ($app,$self) {
            $self->setVariables();
            
            if(!$self->checkPermission()) {
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $formValues = $request->request->all();
            
            if(isset($formValues['submit_delete'])) {
                $self->app['conversadb']->deleteUser($id);
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageUserDeleted');
            } else {
                return $app->redirect(ROOT_URL . '/admin/user/list');
            }
        })->before($app['adminBeforeTokenChecker']);
    
        $controllers->get('user/conversation/{userId}', function (Request $request,$userId) use ($app,$self) {
            $self->setVariables();
            
            if(!$self->checkPermission()) {
                return $app->redirect(ROOT_URL . '/admin/user/list?msg=messageNoPermission');
            }

            $count = $self->app['conversadb']->getConversationHistoryCount($userId);
            
            $page = $request->get('page');
            if(empty($page)) {
                $page = 1;
            }
            
            $msg = $request->get('msg');
            if(!empty($msg)) {
                $self->setInfoAlert($self->language[$msg]);
            }
            
            $conversationHistory = $self->app['conversadb']->getConversationHistory($userId,($page-1)*ADMIN_LISTCOUNT,ADMIN_LISTCOUNT);
            
            // convert timestamp to date
            for($i = 0 ; $i < count($conversationHistory) ; $i++) {
                $conversationHistory[$i]['created'] = date("Y.m.d H:i:s",$conversationHistory[$i]['created']);
            }

            $user = $self->app['conversadb']->findUserById($userId,false);
            
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
    
    public function validate($request,$editmode = false,$userId = "") {
        $formValues = $request->request->all();
        $validationResult = true;
        
        if($editmode) {
            if(empty($formValues['name']) || empty($formValues['email']) || empty($formValues['max_contact_count'])) {
                $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                $validationResult = false;
            }

            if(isset($formValues['chkbox_change_password']) && empty($formValues['password'])) {
                $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                $validationResult = false;
            }
        } else {
            if(empty($formValues['name']) || empty($formValues['email']) || empty($formValues['password']) || empty($formValues['max_contact_count'])) {
                $this->setErrorAlert($this->language['messageValidationErrorRequired']);
                $validationResult = false;
            }
        }

        // numeric
        if(!empty($formValues['max_contact_count']) && !is_numeric($formValues['max_contact_count'])) {
            $this->setErrorAlert($this->language['formMaxContacts'] . " " . $this->language['messageValidationErrorNumeric']);
            $validationResult = false;
        }

        if($editmode) {
            // check name is unique
            $check = $this->app['conversadb']->findUserByEmailOrName($formValues['name'], 1);
            if($check == 0 || $check != $userId) {
                $this->setErrorAlert($this->language['messageValidationErrorUserNameNotUnique']);
                $validationResult = false;
            }
    
            // check email is unique
            $check = $this->app['conversadb']->findUserByEmailOrName($formValues['email'], 2);
            if($check == 0 || $check != $userId) {
                $this->setErrorAlert($this->language['messageValidationErrorUserEmailNotUnique']);
                $validationResult = false;
            }
        } else {
            // check name is unique
            $check = $this->app['conversadb']->findUserByEmailOrName($formValues['name'], 1);
            if($check == 0) {
                $this->setErrorAlert($this->language['messageValidationErrorUserNameNotUnique']);
                $validationResult = false;
            }
    
            // check email is unique
            $check = $this->app['conversadb']->findUserByEmailOrName($formValues['email'], 2);
            if($check == 0) {
                $this->setErrorAlert($this->language['messageValidationErrorUserEmailNotUnique']);
                $validationResult = false;
            }
        }

        if($request->files->has("file")){
            $file = $request->files->get("file");
            
            if($file && $file->isValid()) {
                $mimeType = $file->getClientMimeType();
                
                if(!preg_match("/jpeg/", $mimeType)) {
                    $this->setErrorAlert($this->language['messageValidationErrorFormat']);
                    $validationResult = false;
                }
            }
        }
        
        return $validationResult;
    }
    
    
    public function getGroupCategoryList() {
        $result = $this->app['conversadb']->findAllGroupCategory();
        $list = array();
        
        foreach($result['rows'] as $row) {
            $list[$row['value']['_id']] = $row['value'];
        }
        
        return $list;
    }
    
    public function getEmptyFormData() {
        return  array(
            'name'          =>'',
            'email'         =>'',
            'password'      =>'',
            'about'         =>'',    
            'online_status' => '',
            'birthday'      => '',
            'gender'        => ''
        );
    }
    
}
