<?php
// Script de instalação do banco de dados a partir do arquivo SQL.
$host = 'localhost';
$user = 'root';
$pass = '';
$schemaFile = __DIR__ . '/../database/schema.sql';

if (!file_exists($schemaFile)) {
    echo "Arquivo de schema não encontrado: $schemaFile\n";
    exit(1);
}

$sql = file_get_contents($schemaFile);
if ($sql === false) {
    echo "Falha ao ler o arquivo de schema.\n";
    exit(1);
}

$connection = new mysqli($host, $user, $pass);
if ($connection->connect_error) {
    echo "Falha na conexão MySQL: " . $connection->connect_error . "\n";
    exit(1);
}

$connection->autocommit(false);

$delimiter = ';';
$query = '';
$errors = [];

$lines = preg_split('/\R/', $sql);
foreach ($lines as $line) {
    $trimmed = trim($line);
    if ($trimmed === '') {
        continue;
    }

    if (stripos($trimmed, 'DELIMITER ') === 0) {
        $delimiter = trim(substr($trimmed, 9));
        continue;
    }

    if ($delimiter !== ';' && $trimmed === $delimiter) {
        $statement = trim(substr($query, 0, -strlen($delimiter)));
        if ($statement !== '') {
            if (!$connection->multi_query($statement)) {
                $errors[] = $connection->error;
                break;
            }
            while ($connection->more_results() && $connection->next_result()) {
                if ($result = $connection->store_result()) {
                    $result->free();
                }
            }
        }
        $query = '';
        continue;
    }

    $query .= $line . "\n";

    if ($delimiter === ';' && substr(trim($query), -1) === ';') {
        $statement = trim($query);
        if ($statement !== '') {
            if (!$connection->multi_query($statement)) {
                $errors[] = $connection->error;
                break;
            }
            while ($connection->more_results() && $connection->next_result()) {
                if ($result = $connection->store_result()) {
                    $result->free();
                }
            }
        }
        $query = '';
    }
}

if (count($errors) > 0) {
    echo "Erros ao executar o schema:\n";
    foreach ($errors as $error) {
        echo "- $error\n";
    }
    $connection->rollback();
    $connection->close();
    exit(1);
}

$connection->commit();
$connection->close();
echo "Banco de dados criado e configurado com sucesso.\n";
