<?php

namespace Conversa;

class Utils{
    
    static private function crypto_rand_secure($min, $max) {
        $range = $max - $min;
        
        if ($range < 0) { return $min; } // not so random...
        
        $log    = log($range, 2);
        $bytes  = (int) ($log / 8) + 1; // length in bytes
        $bits   = (int) $log + 1; // length in bits
        $filter = (int) (1 << $bits) - 1; // set all lower bits to 1
        do {
            $rnd = hexdec(bin2hex(openssl_random_pseudo_bytes($bytes)));
            $rnd = $rnd & $filter; // discard irrelevant bits
        } while ($rnd >= $range);
        
        return $min + $rnd;
    }

    /**
     * Genera una cadena de texto con caracteres aleatorios
     * 
     * @param int $min
     * @param int $max
     * @return string Una cadena de texto como Token
     */
    static public function randString($min = 5, $max = 8){
        $length = mt_rand($min, $max);
        $token = "";
        $codeAlphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        $codeAlphabet.= "abcdefghijklmnopqrstuvwxyz";
        $codeAlphabet.= "0123456789";
        $to = strlen($codeAlphabet) - 1;
        
        for($i = 0; $i < $length; $i++){
            $token .= $codeAlphabet[\Conversa\Utils::crypto_rand_secure(0,$to)];
        }
        return $token;
    }
    
    /**
     * Verifica si el parametro es valido
     * 
     * @param string $email
     * @return int devuelve 1 si el <i>email</i>
     * concuerda con la expresion regular <i>regex</i>, 
     * 0 si no lo hace, o <b>FALSE</b> si ocurre un error.
     */
    static public function checkEmailIsValid($email) {
        if( filter_var($email, FILTER_VALIDATE_EMAIL) ) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * Verifica si el password es valido. El password debe contener por lo menos<br></br>
     * un numero, una letra minuscula, una letra mayuscula y un simbolo especial.<br></br>
     * Ademas debe tener una longitud minima de 6 caracteres y maxima de 25.
     * 
     * @param string $password
     * @return int devuelve 1 si el <i>password</i>
     * concuerda con la expresion regular <i>regex</i>, 
     * 0 si no lo hace, o <b>FALSE</b> si ocurre un error.
     */
    static public function checkPasswordIsValid($password) {
        $regex = '/^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W).{6,25}$/'; 
        return preg_match($regex, $password);
    }
    
    /**
     * Genera un ID de 7 caracteres en base al nombre del negocio
     * 
     * @param string $name
     * @return string
     */
    static public function generateConversaIdForBusiness($name) {
        if(strlen($name) < 1) { return ""; } // Verificar que no sea vacio
        
        $name   = trim($name);
        $result = preg_replace('/\s+/', '', $name);
        $characters  = '35';
        $characters .= $result;
        $characters .= '79';
        
        $randstring = '';
        $to = strlen($characters) - 1;
        for ($i = 0; $i < 6; $i++) {
            $randstring .= $characters[mt_rand(0,$to)];
        }
        
        return $randstring;
    }
    
    static public function validateDate($date, $format = 'Y-m-d H:i:s') {
        $d = \DateTime::createFromFormat($format, $date);
        return $d && $d->format($format) == $date;
    }
}