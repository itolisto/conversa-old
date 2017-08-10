<?php
/**
 * Created by IntelliJ IDEA.
 * User: dinko
 * Date: 10/22/13
 * Time: 2:45 PM
 * To change this template use File | Settings | File Templates.
 */

namespace Conversa\Controller;

use Silex\Application;
use Symfony\Component\HttpFoundation\Request;

class CategoryController extends ConversaBaseController {


    public function connect(Application $app) {
        $controllers = $app['controllers_factory'];
        $self = $this;

        $this->setupCategoryMethod($self,$app,$controllers);
        $this->setupCategoryBusinessMethod($self,$app,$controllers);

        return $controllers;
    }

    /**
     * Función para validar el ingreso a la aplicación
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupCategoryMethod($self,$app,$controllers){
        $controllers->get('/allCategories', function (Request $request) use ($app,$self) {
            
            $result = $app['conversadb']->getAllCategories();
                    
            if(!is_null($result)) {
                return json_encode($result);
            } else {
                return $self->returnErrorResponse("An error has occured while retrieving categories.");
            }
        })->before($app['beforeApiGeneral']);
    }

    /**
     * Ver todos los negocios en una categoria excepto el que llama esta funcion<br></br>
     * Solamente si accede a la categoria a la que pertenece.
     * 
     * @param type $self
     * @param type $app
     * @param type $controllers
     */
    private function setupCategoryBusinessMethod($self,$app,$controllers){
        $controllers->post('/allCategoryBusinessByUser', function (Request $request) use ($app,$self) {
            $requestBody = $request->getContent();
            
            if(!$self->validateRequestParams($requestBody,array(
                'category'
            ))){
                return $self->returnErrorResponse("insufficient params");
            }
            
            $requestBodyAry = json_decode($requestBody,true);
            $idcategory = $requestBodyAry['category'];
            
            $allBusiness = $app['conversadb']->getAllBusinessByCategory($idcategory);
            
            if(!is_null($allBusiness)) {
                return json_encode($allBusiness);
            }else{
                return $self->returnErrorResponse("An error has occured while retrieving business.");
            }
            
        })->before($app['beforeApiGeneral'])->before($app['beforeTokenChecker']);
    }
}