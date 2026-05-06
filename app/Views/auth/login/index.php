<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Sistema Vocacional</title>
    <link href="<?php echo BASE_URL; ?>public/assets/css/bootstrap.min.css" rel="stylesheet">
    <link href="<?php echo BASE_URL; ?>public/assets/css/select2.min.css" rel="stylesheet">
    <link href="<?php echo BASE_URL; ?>public/assets/css/app.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="text-center mb-5">
                    <a href="index.html">
                        <i class="fas fa-graduation-cap fa-3x text-primary mb-3"></i>
                    </a>
                    <h2 class="fw-bold">Acessar Sistema</h2>
                    <p class="text-muted">Entre com suas credenciais para acessar sua conta.</p>
                </div>

                <div class="card shadow-sm border-0">
                    <div class="card-body p-4">
                        <form id="formLogin">
                            <div class="mb-3">
                                <label for="email" class="form-label">E-mail</label>
                                <input type="email" class="form-control" id="email" placeholder="seu@email.com" required>
                            </div>
                            <div class="mb-3">
                                <label for="senha" class="form-label">Senha</label>
                                <input type="password" class="form-control" id="senha" required>
                                <div class="form-text text-end">
                                    <a href="recuperar-senha.html">Esqueci minha senha</a>
                                </div>
                            </div>
                            <div class="form-check mb-4">
                                <input class="form-check-input" type="checkbox" id="lembrar">
                                <label class="form-check-label" for="lembrar">Lembrar de mim</label>
                            </div>
                            <div class="d-grid">
                                <button type="submit" class="btn btn-primary btn-lg">
                                    <i class="fas fa-sign-in-alt me-2"></i> Entrar
                                </button>
                            </div>
                        </form>

                        <hr class="my-4">
                        <div class="text-center">
                            <p class="mb-0">Ainda não tem conta? <a href="cadastro.html">Cadastre-se aqui</a></p>
                        </div>
                    </div>
                </div>

                <!-- Seleção de Tipo de Usuário (simplificado) -->
                <div class="text-center mt-4">
                    <p class="text-muted">Acesso para administradores:</p>
                    <a href="admin/index.html" class="btn btn-outline-secondary btn-sm">
                        <i class="fas fa-cog me-1"></i> Painel Admin
                    </a>
                </div>
            </div>
        </div>
    </div>

   

    <script src="<?php echo BASE_URL; ?>public/assets/js/jquery.min.js"></script>
<script src="<?php echo BASE_URL; ?>public/assets/js/bootstrap.bundle.min.js"></script>
<script src="<?php echo BASE_URL; ?>public/assets/js/sweetalert2.min.js"></script>
<script src="<?php echo BASE_URL; ?>public/assets/js/select2.min.js"></script>
<script src="<?php echo BASE_URL; ?>public/assets/js/app.js"></script>
    <script>
        document.getElementById('formLogin').addEventListener('submit', function(e) {
            e.preventDefault();
            // Simulação de login (em produção seria autenticação PHP/MySQL)
            Swal.fire('Login realizado!', 'Redirecionando para o painel...', 'success')
                .then(() => {
                    window.location.href = 'painel-estudante.html';
                });
        });
    </script>
</body>
</html>