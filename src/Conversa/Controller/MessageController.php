<?php
/**
 * Created by IntelliJ IDEA.
 * User: dinko
 * Date: 10/24/13
 * Time: 10:47 AM
 * To change this template use File | Settings | File Templates.
 */

namespace Conversa\Controller;

use Silex\Application;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class MessageController extends ConversaBaseController {
    
    public function connect(Application $app){
        $controllers = parent::connect($app);
        $self = $this;

        $this->setupEmoticonsMethod($self,$app,$controllers);
        $this->setupMessageMethod($self,$app,$controllers);

        return $controllers;
    }

    private function setupEmoticonsMethod($self,$app,$controllers){

        $controllers->get('/Emoticons', function () use ($app,$self) {

            $result = $app['conversadb']->getEmoticons();

            if($result == null){
                return $self->returnErrorResponse("load emoticons error");
            }

            return json_encode($result);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);

        $controllers->get('/Emoticon/{id}', function (Request $request,$id = "") use ($app,$self) {

            if(empty($id)) {
                return $self->returnErrorResponse("please specify emoticon id");
            }

            $emoticonData = $app['conversadb']->getEmoticonAvatarById($id);
            $fileID = $emoticonData['file_id'];

            if($emoticonData == null) {
                return $self->returnErrorResponse("load emoticon error");
            }

            $filePath = $filePath = __DIR__.'/../../../'.FileController::$fileDirName."/".basename($fileID);
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

        })->before($app['beforeApiGeneral']);
    }

    private function setupMessageMethod($self,$app,$controllers){
    
        $controllers->post('/sendMessage', function (Request $request)use($app,$self) {
            
            $currentUser = $app['currentUser'];
            $messageData = $request->getContent();

            if(!$self->validateRequestParams($messageData,
                    array( 'to_user_id', 'to_user_type' ))) {
                return $self->returnErrorResponse("insufficient params");
            }

            $messageDataArray   = json_decode($messageData,true);
            $fromUserId         = $currentUser['_id'];
            $toUserId           = trim($messageDataArray['to_user_id']);

            if(isset($messageDataArray['body'])) {
                $message = $messageDataArray['body'];
            } else {
                $message = "";
            }
            
            if(isset($messageDataArray['message_type'])){
                $messageType = $messageDataArray['message_type'];
            } else {
                $messageType = 0;
            }
            
            $picture = ''; $picture_thumb = '';
            $longitude = 0; $latitude = 0;
            
            switch ($messageType) {
                case 2:// image message
                    if(isset($messageDataArray['picture_file_id'])){
                        $picture       = $messageDataArray['picture_file_id'];
                    }

                    if(isset($messageDataArray['picture_thumb_file_id'])){
                        $picture_thumb = $messageDataArray['picture_thumb_file_id'];
                    }
                    break;
                case 3:// location message
                    if(isset($messageDataArray['longitude'])){
                        $longitude = floatval($messageDataArray['longitude']);
                    }

                    if(isset($messageDataArray['latitude'])){
                        $latitude  = floatval($messageDataArray['latitude']);
                    }
                    break;
            }

            $result = $app['conversadb']->addNewMessage(
                        $messageDataArray['to_user_type'],$currentUser['type'],
                        $fromUserId,$toUserId,$message,$messageType,$picture,$picture_thumb,$longitude,$latitude
                    );

            if($result == null) {
                 return $self->returnErrorResponse("Failed to send message");
            } else {
                $newMessageId = $result['id'];
                // send async request
                $self->doAsyncRequest(
                    $app,$request,"notifyNewMessage",
                    array(
                        'messageId' => $newMessageId
                    )
                );
                
                return json_encode($result);
            }
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        
        $controllers->get('/userMessages/{toUserId}/{count}/{offset}', function ($toUserId = "",$count = 30,$offset = 0) use ($app,$self) {

            $userId     = $app['currentUser']['_id'];
            $userType   = $app['currentUser']['type'];
            $count = intval($count);
            $offset = intval($offset);

            if(empty($toUserId)) {
                return $self->returnErrorResponse("Failed to get messages");
            }

            $result = $app['conversadb']->getUserMessages($userType,$userId,$toUserId,$count,$offset);

            if($result == null) {
                return $self->returnErrorResponse("Failed to get messages");
            }

            if (count($result['rows']) == 0 || count($result['rows']) < $count) {
                $result['stop'] = true;
            }

            //MODIFY WHEN IMPLEMENTING BUSINESS TO BUSINESS MESSAGING
            switch($userType) {
                case USER_TYPE:
                    $toType = BUSINESS_TYPE;
                    break;
                case BUSINESS_TYPE:
                    $toType = USER_TYPE;
                    break;
                default:
                    $toType = 0;
                    break;
            }
            
            $app['conversadb']->updateReadAtAll($userId,$toUserId,$userType,$toType);

            return json_encode($result);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        $controllers->post('/setReadAt', function (Request $request) use ($app,$self) {

            $requestBody = $request->getContent();
            
            if(!$self->validateRequestParams($requestBody,array(
                        'to_user_id', 'to_user_type'
                    ))){
                return $self->returnErrorResponse("insufficient params");
            }
            
            $requestBodyArray = json_decode($requestBody,true);

            $from     = $app['currentUser']['_id'];
            $fromType = $app['currentUser']['type'];
            $to       = trim($requestBodyArray['to_user_id']);
            $toType   = trim($requestBodyArray['to_user_type']);

            $result = $app['conversadb']->updateReadAtAll($from,$to,$fromType,$toType);
            
            if($result > 0) {
                 // send async request
                $self->doAsyncRequest(
                        $app,$request,"notifyReadAt",
                        array('toId' => $to,'fromId' => $from, 'toType' => $toType, 'fromType' => $fromType));   
            }

            return json_encode(array('ok' => $result));
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        $controllers->get('/findMessageById/{id}', function ($id) use ($app,$self) {
                
            $result = $app['conversadb']->findMessageById($id);
            if($result == null) {
                 return $self->returnErrorResponse("failed to get message");
            }

            return json_encode($result);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);

        
        $controllers->post('/findMessagesById', function (Request $request) use ($app,$self) {
                
            $requestBody = $request->getContent();
            
            if(!$self->validateRequestParams($requestBody,array(
                        'to_user_id', 'last_message_id'
                    ))){
                return $self->returnErrorResponse("insufficient params");
            }
            
            $requestBodyArray = json_decode($requestBody,true);

            $from     = $app['currentUser']['_id'];
            $fromType = $app['currentUser']['type'];
            $to       = trim($requestBodyArray['to_user_id']);
            $lastId   = trim($requestBodyArray['last_message_id']);

            $result = $app['conversadb']->getAllMessagesFrom($from,$to,$fromType,$lastId);

            if($result == null) {
                 return $self->returnErrorResponse("failed to get messages");
            }

            return json_encode($result);
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
        
        $controllers->get('/reportViolation', function (Request $request) use ($app,$self) {
                $messageId = $request->get('message_id');
                $app['conversadb']->reportMessage($messageId); 
                return 'OK';
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);   
    }
}
