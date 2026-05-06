<?php
class LoginController extends Controller {
    public function index() {
        $this->view('login/index');
    }

    public function authenticate() {
        // Lógica de autenticação aqui
        // Por enquanto, redirecionar para home
        header('Location: /projectos/IndicacaoVocacional/');
    }
}
?>