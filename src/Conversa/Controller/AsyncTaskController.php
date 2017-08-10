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

class AsyncTaskController extends ConversaBaseController {
    
    public function connect(Application $app) {
        $controllers = parent::connect($app);

        $self = $this;

        $controllers->post('/notifyNewMessage', function (Request $request) use ($self,$app) {
            
            set_time_limit(60 * 2);
            
            $host = $request->getHttpHost();
            
            if($host != "localhost"){
                return $self->returnErrorResponse("Invalid access to internal API");
            }

            $requestBody = $request->getContent();
            $requestData = json_decode($requestBody,true);

            if(empty($requestData['messageId'])) {
                return $self->returnErrorResponse("Insufficient params");
            }

            $messageId  = $requestData['messageId'];
            $message    = $app['conversadb']->findMessageById($messageId);
            // send push notification
            $fromUserId = $message['from_user_id'];
            $toUserId   = $message['to_user_id'];

            switch($message['from_user_type']) {
                case USER_TYPE:
                    $fromUser = $app['conversadb']->findUserById($fromUserId,true,true,0);
                    break;
                case BUSINESS_TYPE:
                    $fromUser = $app['conversadb']->findBusinessByIdApp($fromUserId);
                    break;
                default:
                    $fromUser = null;
                    break;
            }
            
            switch($message['to_user_type']) {
                case USER_TYPE:
                    $toUser = $app['conversadb']->findUserById($toUserId,true,true,3);
                    break;
                case BUSINESS_TYPE:
                    $toUser = $app['conversadb']->findBusinessToPush($toUserId,$fromUserId);
                    break;
                default:
                    $toUser = null;
                    break;
            }
            
            switch($message['message_type']) {
                case MTEXT_TYPE:
                    if(strlen($message['body']) > 20) {
                        $messageContent = substr($message['body'], 0, 20);
                    } else {
                        $messageContent = $message['body'];
                    }
                    break;
                case MIMAGE_TYPE:
                    $messageContent = "Image";
                    break;
                case MLOCATION_TYPE:
                    $messageContent = "Location";
                    break;
            }

            // send iOS push notification
            if(!is_null($toUser) && !is_null($fromUser)) {
//                if(!empty($toUser['ios_push_token'])){
//                    $body = array();
//                    $body['aps']  = array('alert' => $messageId, 'badge' => 0, 'sound' => 'default', 'value' => "");
//                    $body['data'] = array('fromUser' => $fromUserId, 'fromUserName'  => $fromUser['name']);
//                    $payload = json_encode($body);
//
//                    $app['sendProdAPN'](array($toUser['ios_push_token']),$payload);
//                    $app['sendDevAPN'](array($toUser['ios_push_token']),$payload);
//                }

                // send Android push notification
                if(!empty($toUser['android_push_token'])){

                    $registrationIDs = array($toUser['android_push_token']);

                    $fields = array(
                        'registration_ids' => $registrationIDs,
                        'data' => array( 
                            "messageId"      => $messageId,
                            "fromUser"       => $fromUserId,
                            "fromUserName"   => $fromUser['name'],
                            "messageContent" => $messageContent
                        ),
                    );

                    $payload = json_encode($fields);
                    $app['sendGCM']($payload,$app);
                }
            }
            
            return "";
        });
        
        $controllers->post('/notifyReadAt', function (Request $request) use ($self,$app) {
            
            set_time_limit(60 * 2);
            
            $host = $request->getHttpHost();
            
            if($host != "localhost"){
                return $self->returnErrorResponse("Invalid access to internal API");
            }

            $requestBody = $request->getContent();
            $requestData = json_decode($requestBody,true);

            if( empty($requestData['fromId']) || empty($requestData['toId']) ||
                empty($requestData['fromType']) || empty($requestData['toType']) ) {
                return $self->returnErrorResponse("Insufficient params");
            }

            // send push notification
            $fromUserId   = $requestData['fromId'];
            $fromUserType = $requestData['fromType'];
            $toUserId     = $requestData['toId'];
            $toUserType   = $requestData['toType'];
            
            $toUser = null;
            
            //MODIFY WHEN IMPLEMENTING BUSINESS TO BUSINESS MESSAGING
            switch($fromUserType) {
                case USER_TYPE:
                    $toUser = $app['conversadb']->findBusinessToPush($toUserId,$fromUserId);
                    break;
                case BUSINESS_TYPE:
                    $toUser = $app['conversadb']->findUserById($toUserId,true,true,3);
                    break;
                default:
                    $toUser = null;
                    break;
            }

            if(!is_null($toUser)) {
                // send iOS push notification
                if(!empty($toUser['ios_push_token'])){
                    $body = array();
                    $body['aps']  = array('alert' => DIRECTMESSAGE_NOTIFICATION_READ, 'badge' => 0, 'sound' => 'default', 'value' => "");
                    $body['data'] = array('toUser' => $toUserId, "toUserType" => $toUserType);
                    $payload = json_encode($body);

                    $app['sendProdAPN'](array($toUser['ios_push_token']),$payload);
                    $app['sendDevAPN'](array($toUser['ios_push_token']),$payload);
                }

                // send Android push notification
                if(!empty($toUser['android_push_token'])){

                    $registrationIDs = array($toUser['android_push_token']);

                    $fields = array(
                                    'registration_ids' => $registrationIDs,
                                    'data' => array( 
                                            "read"       => DIRECTMESSAGE_NOTIFICATION_READ, 
                                            "toUser"     => $toUserId,
                                            "toUserType" => $toUserType
                                            ),
                                   );

                    $payload = json_encode($fields);
                    $app['sendGCM']($payload,$app);
                }
            }

            return "";
        });

        return $controllers;
    }
}