<?php
namespace Conversa\Middleware;

use Conversa\Db\DbInterface;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class TokenChecker {
    /**
     * @var Conversa\Db\DbInterface
     */
    private $db;

    /**
     * @var Psr\Log\LoggerInterface
     */
    private $logger;

    public function __construct(DbInterface $db, LoggerInterface $logger) {
        $this->db     = $db;
        $this->logger = $logger;
    }

    public function __invoke(Request $request,\Silex\Application $app) { 
        
        $tokenReceived  = $request->headers->get('token');
        $type           = $request->headers->get('type');
        $os             = $request->headers->get('os');
        
        if (empty($tokenReceived) || empty($type) || empty($os)) {
            return $this->abortManually("API call forbidden");
        }

        if($type == BUSINESS_TYPE || $type == USER_TYPE) {
            $user = $this->db->findValidToken($tokenReceived,$type);

            if (is_null($user) || empty($user['token'])) {
                return $this->abortManually("Invalid token");
            }
            
            $user['os']         = $os;
            $user['type']       = $type;
            $app['currentUser'] = $user;
        } else {
            return $this->abortManually("User type not valid");
        }
    }

    private function abortManually($errMessage) {
        $arr  = array('message' => $errMessage, 'error' => true);
        $json = json_encode($arr);
        return new Response($json, 403);
    }
}
