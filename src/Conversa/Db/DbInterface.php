<?php
namespace Conversa\Db;

interface DbInterface {
    /********************** FOR WEB ONLY **********************/
    //Dashboard
    public function findUserCount();
    public function getMessageCount();
    public function getLastLoginedUsersCount();
    //Log in/out
    public function doConversaAdminAuth($email,$password);
    public function findAdminById($id);
    //Users
    public function createUser($userName,$email,$password,$birthday,$gender,$about,$onlineStatus,$avatarFile,$thumbFile);
    public function updateUser($userId,$user,$secure);
    public function deleteUser($id);
    public function getContactsByUserId($userId);
    public function getContactedByUserId($userId);
    public function findAllUsersWithPagingWithCriteria($offect,$count,$criteria,$criteriaValues);
    public function findUserCountWithCriteria($criteria,$criteriaValues);
    //Commerces
    public function createBusiness($name,$email,$password,$about,$founded,$expired,$avatarFile,$thumbFile,$max_devices,$country,$id_category,$plan);
    public function updateBusiness($userId,$user,$secure);
    public function deleteBusiness($businessId);
    public function findBusinessCountWithCriteria($criteria);
    public function findAllBusinessWithPagingWithCriteria($offect,$count,$criteria);
    //Categories
    public function getAllCategoryName();
    public function findCategoryCount();
    public function findAllCategoryWithPaging($count,$offset);
    public function createCategory($title,$picture);
    public function findCategoryById($id);
    public function findCategoryByName($name);
    public function updateCategory($id,$title,$picture);
    public function deleteCategory($id);
    //Emoticons
    public function getEmoticons();
    public function getEmoticonAvatarById($id);
    public function createEmoticon($identifier,$picture);
    public function getEmoticonByName($identifier);
    public function findAllEmoticonsWithPaging($count,$offset);
    public function findEmoticonCount();
    public function findEmoticonById($id);
    public function updateEmoticon($id,$title,$picture);
    public function deleteEmoticon($id);
    //Server
    public function findServersCount();
    public function findAllServersWithPaging($offset=0,$count=0);
    public function createServer($name,$url);
    public function findServerById($id);
    public function updateServer($server_id,$name,$url);
    public function deleteServer($id);
    public function findAllServersWithoutId();
    /********************** FOR APP ONLY **********************/
    //General
    public function checkEmailIsUnique($email);
    public function checkUserNameIsUnique($name);
    //Sign up - Log in
    public function doConversaAuth($email,$password);
    public function doConversaBusinessAuth($email,$password,$os);
    //Users
    public function findUserById($id,$deletePersonalInfo,$deletePassword,$os);
    public function findUserByEmailOrName($value,$action);
    public function updateUserAppData($userId,$action,$value);
    //Categories
    public function getAllCategories();
    public function getAllBusinessByCategory($category);
    //Commerces
    public function findBusinessById($id,$deletePersonalInfo,$deletePassword);
    public function findBusinessByIdApp($id);
    public function findBusinessByEmailOrName($value,$action);
    public function findBusinessToPush($id,$fromId);
    public function updateBusinessAppData($userId,$action,$value,$token);
    public function blockContact($id,$targetId,$type,$targetType,$action);
    public function getBusinessStatistics($id,$pushId);
    public function addRemoveLocation($id,$pushId,$action);
    //Utils
    public function findContactsById($id,$user_type);
    public function getAvatarFileId($user_id);
    public function getAvatarFileIdForBusiness($_id);
    public function addContact($userId,$targetId);
    public function addContactBusiness($userId,$targetId,$pushId);
    public function removeContact($userId,$targetId);
    public function removeContactBusiness($id,$targetId,$pushId);
    public function addRemoveFavorite($userId,$targetId,$action);
    //Messaging
    public function addNewMessage($toUserType,$fromUserType,$fromUserId,$toUserId,$message,$messageType,$picture,$picture_thumb,$longitude,$latitude);
    public function getUserMessages($ownerType,$ownerUserId,$targetUserId,$count,$offset);
    public function getAllMessagesFrom($from,$to,$fromType,$lastId);
    public function findMessageById($messageId);
    public function updateReadAtAll($from,$to,$fromType,$toType);
    public function deleteMessage($messageId);
    public function reportMessage($messageId);
    //Password Reset
    public function addPassworResetRequest($toUserId);
    public function getPassworResetRequest($requestCode);
    public function changePassword($userId,$newPassword);
    //Search
    public function searchForBusiness($target,$userId,$count,$offset);
    public function searchForBusinessByCategory($target,$userId,$category,$count,$offset);
    /******************* FOR TOKEN VALIDATION *******************/
    public function findValidToken($token,$type);
    public function findBusinessByToken($token);
    public function findUserByToken($token);

    
    public function getAllCountries();
    public function getConversationHistory($user,$offset,$count);
    public function getConversationHistoryCount($user);
}