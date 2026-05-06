<?php
// Arquivo de inicialização da aplicação
require_once 'app/core/App.php';
require_once 'app/core/Controller.php';
require_once 'app/core/Model.php';

// Carregar configurações
require_once 'config/database.php';

// Incluir rotas
require_once 'routes/web.php';
?>