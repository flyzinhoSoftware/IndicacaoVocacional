<?php require_once 'app/Views/shared/header.php'; ?>
<h2>Login</h2>
<form action="/projectos/IndicacaoVocacional/login/authenticate" method="post">
    <label for="username">Usuário:</label>
    <input type="text" id="username" name="username" required>
    <label for="password">Senha:</label>
    <input type="password" id="password" name="password" required>
    <button type="submit">Entrar</button>
</form>
<?php require_once 'app/Views/shared/footer.php'; ?>
