<?php
namespace Conversa\Middleware;

use Conversa\Db\DbInterface;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpFoundation\Request;

class APIGeneralBeforeHandler {
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
        // maintainance mode
        // return new Response("maintainance mode", 503);
    }
}
