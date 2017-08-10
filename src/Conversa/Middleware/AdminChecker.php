<?php
namespace Conversa\Middleware;

use Symfony\Component\HttpFoundation\Request;

class AdminChecker {
    private $username;
    private $password;
    private $app;
    
    /**
     * Constructor que recibe y define el entorno
     * de la aplicación
     * 
     * @param type $app
     */
    public function __construct($app) {
        $this->app = $app;
    }

    /**
     * Antes de ejecutar cualquier acción en los controladores
     * se llama a este método para verificar que el usuario se
     * encuentre activo
     * 
     * @param Request $request
     * @param \Silex\Application $app
     * @return type
     */
    public function __invoke(Request $request,\Silex\Application $app) {
        if ($app['session']->get('user') === null) {
            return $app->redirect(ROOT_URL . '/admin/login');
        }
    }
}
