-- ============================================
-- BANCO DE DADOS: Sistema de Orientação Vocacional
-- ESCOLA: Escola Secundária Geral Eduardo Mondlane
-- LOCAL: Quelimane, Moçambique
-- ANO: 2025
-- ============================================

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS sistema_orientacao_vocacional;
USE sistema_orientacao_vocacional;

-- ============================================
-- TABELA: usuarios (Classe Base)
-- ============================================
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL, -- Hash bcrypt
    tipo ENUM('estudante', 'administrador') NOT NULL,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultimo_acesso DATETIME,
    status ENUM('ativo', 'inativo', 'suspenso') DEFAULT 'ativo',
    telefone VARCHAR(20),
    endereco TEXT,
    INDEX idx_email (email),
    INDEX idx_tipo (tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: estudantes (Herda de usuarios)
-- ============================================
CREATE TABLE estudantes (
    id INT PRIMARY KEY,
    matricula VARCHAR(20) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    sexo ENUM('M', 'F', 'Outro'),
    nome_escola VARCHAR(100) DEFAULT 'Escola Secundária Geral Eduardo Mondlane',
    classe VARCHAR(10), -- Ex: '12ª Classe'
    turma VARCHAR(10),
    ano_lectivo YEAR DEFAULT 2025,
    nome_responsavel VARCHAR(100),
    telefone_responsavel VARCHAR(20),
    tem_computador BOOLEAN DEFAULT FALSE,
    tem_internet BOOLEAN DEFAULT FALSE,
    nivel_conhecimento_digital ENUM('baixo', 'medio', 'alto') DEFAULT 'medio',
    perfil_vocacional_id INT,
    data_questionario_completo DATETIME,
    FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_matricula (matricula),
    INDEX idx_escola (nome_escola),
    INDEX idx_classe (classe)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: administradores (Herda de usuarios)
-- ============================================
CREATE TABLE administradores (
    id INT PRIMARY KEY,
    nivel_acesso ENUM('super', 'normal', 'limitado') DEFAULT 'normal',
    departamento VARCHAR(50),
    cargo VARCHAR(50),
    pode_gerenciar_usuarios BOOLEAN DEFAULT TRUE,
    pode_gerenciar_cursos BOOLEAN DEFAULT TRUE,
    pode_gerenciar_questionarios BOOLEAN DEFAULT TRUE,
    pode_visualizar_relatorios BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: perfis_vocacionais (Tipologia de Holland)
-- ============================================
CREATE TABLE perfis_vocacionais (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo CHAR(1) UNIQUE NOT NULL, -- R, I, A, S, E, C
    nome VARCHAR(50) NOT NULL, -- Realista, Investigativo, Artístico, Social, Empreendedor, Convencional
    descricao TEXT NOT NULL,
    caracteristicas TEXT,
    pontos_fortes TEXT,
    areas_interesse TEXT,
    profissoes_tipicas TEXT,
    cor_hex VARCHAR(7) DEFAULT '#FFFFFF',
    icone VARCHAR(50),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_codigo (codigo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: questionarios
-- ============================================
CREATE TABLE questionarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    versao VARCHAR(10) DEFAULT '1.0',
    numero_perguntas INT DEFAULT 0,
    tempo_estimado_minutos INT DEFAULT 30,
    publico_alvo VARCHAR(50) DEFAULT 'Estudantes Secundários',
    linguagem VARCHAR(10) DEFAULT 'pt',
    status ENUM('ativo', 'inativo', 'desenvolvimento') DEFAULT 'ativo',
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao DATETIME ON UPDATE CURRENT_TIMESTAMP,
    administrador_id INT,
    FOREIGN KEY (administrador_id) REFERENCES administradores(id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: perguntas
-- ============================================
CREATE TABLE perguntas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    questionario_id INT NOT NULL,
    numero_ordem INT NOT NULL,
    texto TEXT NOT NULL,
    tipo ENUM('multipla_escolha', 'likert', 'aberta') DEFAULT 'multipla_escolha',
    perfil_associado CHAR(1), -- R, I, A, S, E, C
    peso INT DEFAULT 1, -- Peso da pergunta (1-5)
    ajuda_contexto TEXT,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (questionario_id) REFERENCES questionarios(id) ON DELETE CASCADE,
    FOREIGN KEY (perfil_associado) REFERENCES perfis_vocacionais(codigo),
    INDEX idx_questionario (questionario_id),
    INDEX idx_perfil (perfil_associado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: alternativas
-- ============================================
CREATE TABLE alternativas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pergunta_id INT NOT NULL,
    texto TEXT NOT NULL,
    valor VARCHAR(10) NOT NULL, -- A, B, C, D ou 1-5 para Likert
    pontuacao_perfil_r INT DEFAULT 0,
    pontuacao_perfil_i INT DEFAULT 0,
    pontuacao_perfil_a INT DEFAULT 0,
    pontuacao_perfil_s INT DEFAULT 0,
    pontuacao_perfil_e INT DEFAULT 0,
    pontuacao_perfil_c INT DEFAULT 0,
    ordem INT DEFAULT 1,
    FOREIGN KEY (pergunta_id) REFERENCES perguntas(id) ON DELETE CASCADE,
    INDEX idx_pergunta (pergunta_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: respostas_estudantes
-- ============================================
CREATE TABLE respostas_estudantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudante_id INT NOT NULL,
    pergunta_id INT NOT NULL,
    alternativa_id INT,
    resposta_valor VARCHAR(10), -- Para respostas abertas
    pontuacao_total INT DEFAULT 0,
    data_resposta DATETIME DEFAULT CURRENT_TIMESTAMP,
    tempo_resposta_segundos INT,
    sessao_id VARCHAR(50),
    FOREIGN KEY (estudante_id) REFERENCES estudantes(id) ON DELETE CASCADE,
    FOREIGN KEY (pergunta_id) REFERENCES perguntas(id),
    FOREIGN KEY (alternativa_id) REFERENCES alternativas(id),
    UNIQUE KEY uk_estudante_pergunta (estudante_id, pergunta_id),
    INDEX idx_estudante (estudante_id),
    INDEX idx_data_resposta (data_resposta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: resultados_perfis
-- ============================================
CREATE TABLE resultados_perfis (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudante_id INT NOT NULL,
    questionario_id INT NOT NULL,
    pontuacao_r INT DEFAULT 0,
    pontuacao_i INT DEFAULT 0,
    pontuacao_a INT DEFAULT 0,
    pontuacao_s INT DEFAULT 0,
    pontuacao_e INT DEFAULT 0,
    pontuacao_c INT DEFAULT 0,
    perfil_primario CHAR(1),
    perfil_secundario CHAR(1),
    perfil_terciario CHAR(1),
    data_calculo DATETIME DEFAULT CURRENT_TIMESTAMP,
    confiabilidade ENUM('alta', 'media', 'baixa') DEFAULT 'media',
    observacoes TEXT,
    FOREIGN KEY (estudante_id) REFERENCES estudantes(id) ON DELETE CASCADE,
    FOREIGN KEY (questionario_id) REFERENCES questionarios(id),
    FOREIGN KEY (perfil_primario) REFERENCES perfis_vocacionais(codigo),
    FOREIGN KEY (perfil_secundario) REFERENCES perfis_vocacionais(codigo),
    FOREIGN KEY (perfil_terciario) REFERENCES perfis_vocacionais(codigo),
    UNIQUE KEY uk_estudante_questionario (estudante_id, questionario_id),
    INDEX idx_perfil_primario (perfil_primario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: areas_formacao
-- ============================================
CREATE TABLE areas_formacao (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    icone VARCHAR(50),
    ordem_prioridade INT DEFAULT 1,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nome (nome)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: cursos
-- ============================================
CREATE TABLE cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    area_formacao_id INT,
    tipo_curso ENUM('superior', 'tecnico', 'profissional', 'curso_livre') DEFAULT 'superior',
    instituicao VARCHAR(150) NOT NULL,
    duracao_meses INT,
    requisitos TEXT,
    descricao TEXT NOT NULL,
    perfil_recomendado_r INT DEFAULT 0, -- 0-10
    perfil_recomendado_i INT DEFAULT 0,
    perfil_recomendado_a INT DEFAULT 0,
    perfil_recomendado_s INT DEFAULT 0,
    perfil_recomendado_e INT DEFAULT 0,
    perfil_recomendado_c INT DEFAULT 0,
    mercado_trabalho TEXT,
    salario_medio DECIMAL(10,2),
    oportunidades_emprego TEXT,
    link_mais_informacoes VARCHAR(255),
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    administrador_id INT,
    status ENUM('ativo', 'inativo') DEFAULT 'ativo',
    FOREIGN KEY (area_formacao_id) REFERENCES areas_formacao(id),
    FOREIGN KEY (administrador_id) REFERENCES administradores(id),
    INDEX idx_nome (nome),
    INDEX idx_instituicao (instituicao),
    INDEX idx_tipo_curso (tipo_curso)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: recomendacoes_cursos
-- ============================================
CREATE TABLE recomendacoes_cursos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudante_id INT NOT NULL,
    curso_id INT NOT NULL,
    resultado_perfil_id INT,
    pontuacao_afinidade DECIMAL(5,2) NOT NULL, -- 0-100
    ranking INT DEFAULT 1,
    justificativa TEXT,
    pontos_positivos TEXT,
    pontos_atencao TEXT,
    data_geracao DATETIME DEFAULT CURRENT_TIMESTAMP,
    visualizado BOOLEAN DEFAULT FALSE,
    favoritado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (estudante_id) REFERENCES estudantes(id) ON DELETE CASCADE,
    FOREIGN KEY (curso_id) REFERENCES cursos(id),
    FOREIGN KEY (resultado_perfil_id) REFERENCES resultados_perfis(id),
    UNIQUE KEY uk_estudante_curso (estudante_id, curso_id),
    INDEX idx_afinidade (pontuacao_afinidade),
    INDEX idx_estudante (estudante_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: relatorios_vocacionais
-- ============================================
CREATE TABLE relatorios_vocacionais (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudante_id INT NOT NULL,
    titulo VARCHAR(100) DEFAULT 'Relatório Vocacional',
    resultado_perfil_id INT,
    dados_perfil TEXT, -- JSON com análise do perfil
    recomendacoes TEXT, -- JSON com cursos recomendados
    formato ENUM('pdf', 'html', 'json') DEFAULT 'pdf',
    caminho_arquivo VARCHAR(255),
    data_geracao DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_download DATETIME,
    numero_downloads INT DEFAULT 0,
    hash_verificacao VARCHAR(64),
    FOREIGN KEY (estudante_id) REFERENCES estudantes(id) ON DELETE CASCADE,
    FOREIGN KEY (resultado_perfil_id) REFERENCES resultados_perfis(id),
    INDEX idx_estudante (estudante_id),
    INDEX idx_data_geracao (data_geracao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: instituicoes_ensino
-- ============================================
CREATE TABLE instituicoes_ensino (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    tipo ENUM('universidade', 'instituto', 'escola_tecnica', 'centro_formacao') DEFAULT 'universidade',
    localizacao VARCHAR(100),
    provincia VARCHAR(50),
    pais VARCHAR(50) DEFAULT 'Moçambique',
    website VARCHAR(255),
    telefone VARCHAR(20),
    email VARCHAR(100),
    descricao TEXT,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ativo', 'inativo') DEFAULT 'ativo',
    INDEX idx_tipo (tipo),
    INDEX idx_provincia (provincia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: logs_acesso
-- ============================================
CREATE TABLE logs_acesso (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT,
    tipo_usuario ENUM('estudante', 'administrador'),
    acao VARCHAR(50) NOT NULL,
    descricao TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    sucesso BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL,
    INDEX idx_usuario (usuario_id),
    INDEX idx_data_hora (data_hora),
    INDEX idx_acao (acao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: sessões
-- ============================================
CREATE TABLE sessoes (
    id VARCHAR(128) PRIMARY KEY,
    usuario_id INT NOT NULL,
    data_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_ultima_atividade DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_expiracao DATETIME,
    ip_address VARCHAR(45),
    user_agent TEXT,
    dispositivo VARCHAR(50),
    ativa BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id),
    INDEX idx_data_expiracao (data_expiracao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: configuracoes_sistema
-- ============================================
CREATE TABLE configuracoes_sistema (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chave VARCHAR(50) UNIQUE NOT NULL,
    valor TEXT,
    tipo VARCHAR(20) DEFAULT 'string',
    descricao TEXT,
    categoria VARCHAR(30) DEFAULT 'geral',
    data_atualizacao DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_chave (chave),
    INDEX idx_categoria (categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABELA: feedback_estudantes
-- ============================================
CREATE TABLE feedback_estudantes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    estudante_id INT NOT NULL,
    tipo_feedback ENUM('sistema', 'questionario', 'recomendacao', 'geral'),
    pontuacao INT CHECK (pontuacao >= 1 AND pontuacao <= 5), -- 1-5 estrelas
    comentario TEXT,
    data_feedback DATETIME DEFAULT CURRENT_TIMESTAMP,
    respondido BOOLEAN DEFAULT FALSE,
    resposta_administrador TEXT,
    data_resposta DATETIME,
    FOREIGN KEY (estudante_id) REFERENCES estudantes(id) ON DELETE CASCADE,
    INDEX idx_estudante (estudante_id),
    INDEX idx_tipo_feedback (tipo_feedback)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- VIEWS PARA CONSULTAS COMUNS
-- ============================================

-- View: Estudantes com questionário completo
CREATE VIEW vw_estudantes_completos AS
SELECT 
    e.id,
    e.matricula,
    u.nome,
    u.email,
    e.classe,
    e.turma,
    e.data_questionario_completo,
    rp.perfil_primario,
    rp.perfil_secundario,
    rp.perfil_terciario,
    (SELECT COUNT(*) FROM recomendacoes_cursos rc WHERE rc.estudante_id = e.id) AS numero_recomendacoes
FROM estudantes e
INNER JOIN usuarios u ON e.id = u.id
LEFT JOIN resultados_perfis rp ON e.id = rp.estudante_id
WHERE e.data_questionario_completo IS NOT NULL;

-- View: Cursos mais recomendados
CREATE VIEW vw_cursos_populares AS
SELECT 
    c.id,
    c.nome,
    c.instituicao,
    c.tipo_curso,
    af.nome AS area_formacao,
    COUNT(rc.id) AS vezes_recomendado,
    AVG(rc.pontuacao_afinidade) AS afinidade_media
FROM cursos c
LEFT JOIN recomendacoes_cursos rc ON c.id = rc.curso_id
LEFT JOIN areas_formacao af ON c.area_formacao_id = af.id
GROUP BY c.id, c.nome, c.instituicao, c.tipo_curso, af.nome
ORDER BY vezes_recomendado DESC;

-- View: Estatísticas de perfis vocacionais
CREATE VIEW vw_estatisticas_perfis AS
SELECT 
    pv.codigo,
    pv.nome AS perfil,
    COUNT(rp.id) AS total_estudantes,
    ROUND((COUNT(rp.id) * 100.0 / (SELECT COUNT(*) FROM resultados_perfis)), 2) AS percentual
FROM perfis_vocacionais pv
LEFT JOIN resultados_perfis rp ON pv.codigo = rp.perfil_primario
GROUP BY pv.codigo, pv.nome
ORDER BY total_estudantes DESC;

-- ============================================
-- PROCEDURES ARMAZENADAS
-- ============================================

-- Procedure: Calcular perfil vocacional de um estudante
DELIMITER //
CREATE PROCEDURE sp_calcular_perfil_estudante(
    IN p_estudante_id INT,
    IN p_questionario_id INT
)
BEGIN
    DECLARE total_r, total_i, total_a, total_s, total_e, total_c INT DEFAULT 0;
    DECLARE perfil_primario, perfil_secundario, perfil_terciario CHAR(1);
    
    -- Calcular pontuações por perfil
    SELECT 
        SUM(COALESCE(a.pontuacao_perfil_r, 0)) AS r,
        SUM(COALESCE(a.pontuacao_perfil_i, 0)) AS i,
        SUM(COALESCE(a.pontuacao_perfil_a, 0)) AS a,
        SUM(COALESCE(a.pontuacao_perfil_s, 0)) AS s,
        SUM(COALESCE(a.pontuacao_perfil_e, 0)) AS e,
        SUM(COALESCE(a.pontuacao_perfil_c, 0)) AS c
    INTO total_r, total_i, total_a, total_s, total_e, total_c
    FROM respostas_estudantes re
    INNER JOIN alternativas a ON re.alternativa_id = a.id
    INNER JOIN perguntas p ON re.pergunta_id = p.id
    WHERE re.estudante_id = p_estudante_id
    AND p.questionario_id = p_questionario_id;
    
    -- Determinar perfis primário, secundário e terciário
    -- (Lógica simplificada - na prática seria mais complexa)
    SET perfil_primario = CASE 
        WHEN total_r >= total_i AND total_r >= total_a AND total_r >= total_s AND total_r >= total_e AND total_r >= total_c THEN 'R'
        WHEN total_i >= total_r AND total_i >= total_a AND total_i >= total_s AND total_i >= total_e AND total_i >= total_c THEN 'I'
        WHEN total_a >= total_r AND total_a >= total_i AND total_a >= total_s AND total_a >= total_e AND total_a >= total_c THEN 'A'
        WHEN total_s >= total_r AND total_s >= total_i AND total_s >= total_a AND total_s >= total_e AND total_s >= total_c THEN 'S'
        WHEN total_e >= total_r AND total_e >= total_i AND total_e >= total_a AND total_e >= total_s AND total_e >= total_c THEN 'E'
        ELSE 'C'
    END;
    
    -- Inserir/Atualizar resultado
    INSERT INTO resultados_perfis (
        estudante_id, questionario_id,
        pontuacao_r, pontuacao_i, pontuacao_a, pontuacao_s, pontuacao_e, pontuacao_c,
        perfil_primario, perfil_secundario, perfil_terciario,
        data_calculo
    ) VALUES (
        p_estudante_id, p_questionario_id,
        total_r, total_i, total_a, total_s, total_e, total_c,
        perfil_primario, NULL, NULL, -- Simplificado
        NOW()
    )
    ON DUPLICATE KEY UPDATE
        pontuacao_r = total_r,
        pontuacao_i = total_i,
        pontuacao_a = total_a,
        pontuacao_s = total_s,
        pontuacao_e = total_e,
        pontuacao_c = total_c,
        perfil_primario = perfil_primario,
        data_calculo = NOW();
    
    -- Atualizar estudante
    UPDATE estudantes 
    SET data_questionario_completo = NOW()
    WHERE id = p_estudante_id;
    
END //
DELIMITER ;

-- Procedure: Gerar recomendações para estudante
DELIMITER //
CREATE PROCEDURE sp_gerar_recomendacoes(
    IN p_estudante_id INT,
    IN p_resultado_perfil_id INT
)
BEGIN
    DECLARE perfil_primario CHAR(1);
    DECLARE done INT DEFAULT FALSE;
    DECLARE curso_id INT;
    DECLARE afinidade DECIMAL(5,2);
    DECLARE ranking_counter INT DEFAULT 1;
    
    -- Cursor para cursos compatíveis
    DECLARE cur_cursos CURSOR FOR
    SELECT c.id,
           CASE 
               WHEN p.perfil_primario = 'R' THEN c.perfil_recomendado_r
               WHEN p.perfil_primario = 'I' THEN c.perfil_recomendado_i
               WHEN p.perfil_primario = 'A' THEN c.perfil_recomendado_a
               WHEN p.perfil_primario = 'S' THEN c.perfil_recomendado_s
               WHEN p.perfil_primario = 'E' THEN c.perfil_recomendado_e
               WHEN p.perfil_primario = 'C' THEN c.perfil_recomendado_c
           END * 10 as afinidade_calculada
    FROM cursos c
    CROSS JOIN resultados_perfis p
    WHERE p.id = p_resultado_perfil_id
    AND c.status = 'ativo'
    ORDER BY afinidade_calculada DESC
    LIMIT 10;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Obter perfil primário
    SELECT perfil_primario INTO perfil_primario 
    FROM resultados_perfis 
    WHERE id = p_resultado_perfil_id;
    
    -- Limpar recomendações anteriores
    DELETE FROM recomendacoes_cursos 
    WHERE estudante_id = p_estudante_id;
    
    OPEN cur_cursos;
    
    read_loop: LOOP
        FETCH cur_cursos INTO curso_id, afinidade;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Inserir recomendação
        INSERT INTO recomendacoes_cursos (
            estudante_id, curso_id, resultado_perfil_id,
            pontuacao_afinidade, ranking, data_geracao
        ) VALUES (
            p_estudante_id, curso_id, p_resultado_perfil_id,
            afinidade, ranking_counter, NOW()
        );
        
        SET ranking_counter = ranking_counter + 1;
    END LOOP;
    
    CLOSE cur_cursos;
END //
DELIMITER ;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger: Atualizar contador de perguntas no questionário
DELIMITER //
CREATE TRIGGER tr_after_insert_pergunta
AFTER INSERT ON perguntas
FOR EACH ROW
BEGIN
    UPDATE questionarios 
    SET numero_perguntas = numero_perguntas + 1
    WHERE id = NEW.questionario_id;
END //
DELIMITER ;

-- Trigger: Atualizar data de última atividade do estudante
DELIMITER //
CREATE TRIGGER tr_after_insert_resposta
AFTER INSERT ON respostas_estudantes
FOR EACH ROW
BEGIN
    UPDATE estudantes e
    INNER JOIN usuarios u ON e.id = u.id
    SET u.ultimo_acesso = NOW()
    WHERE e.id = NEW.estudante_id;
END //
DELIMITER ;

-- Trigger: Log de criação de usuários
DELIMITER //
CREATE TRIGGER tr_after_insert_usuario
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO logs_acesso (usuario_id, tipo_usuario, acao, descricao, data_hora)
    VALUES (NEW.id, NEW.tipo, 'CADASTRO', CONCAT('Novo usuário cadastrado: ', NEW.nome), NOW());
END //
DELIMITER ;

-- ============================================
-- INSERÇÃO DE DADOS INICIAIS
-- ============================================

-- Inserir perfis vocacionais (Tipologia de Holland)
INSERT INTO perfis_vocacionais (codigo, nome, descricao, caracteristicas, areas_interesse, cor_hex) VALUES
('R', 'Realista', 'Pessoas práticas, que gostam de trabalhar com objetos, máquinas, ferramentas, animais ou plantas.', 'Prático, mecânico, atlético, estável, concreto', 'Agricultura, Engenharia, Mecânica, Esportes', '#4CAF50'),
('I', 'Investigativo', 'Pessoas analíticas, intelectuais, que gostam de observar, aprender, investigar e resolver problemas.', 'Analítico, curioso, intelectual, preciso, metódico', 'Ciência, Pesquisa, Medicina, Matemática', '#2196F3'),
('A', 'Artístico', 'Pessoas criativas, que gostam de trabalhar em situações pouco estruturadas usando sua imaginação e criatividade.', 'Criativo, expressivo, intuitivo, independente, original', 'Artes, Música, Teatro, Design, Literatura', '#9C27B0'),
('S', 'Social', 'Pessoas que gostam de trabalhar com outras pessoas para informar, ajudar, treinar ou curar.', 'Sociável, cooperativo, empático, útil, generoso', 'Educação, Saúde, Serviço Social, Psicologia', '#FF9800'),
('E', 'Empreendedor', 'Pessoas que gostam de trabalhar com outras pessoas, influenciando, persuadindo, liderando ou gerenciando.', 'Energético, ambicioso, dominante, persuasivo, otimista', 'Negócios, Direito, Política, Vendas', '#F44336'),
('C', 'Convencional', 'Pessoas que gostam de trabalhar com dados, tendo atividades claras e bem definidas.', 'Organizado, meticuloso, eficiente, prático, cauteloso', 'Administração, Contabilidade, Secretariado, Finanças', '#607D8B');

-- Inserir áreas de formação (Contexto Moçambicano)
INSERT INTO areas_formacao (nome, descricao, ordem_prioridade) VALUES
('Ciências Exatas e Engenharias', 'Engenharias, Matemática, Física, Química', 1),
('Ciências da Saúde', 'Medicina, Enfermagem, Farmácia, Saúde Pública', 2),
('Ciências Humanas e Sociais', 'Direito, Psicologia, Sociologia, História', 3),
('Educação e Formação', 'Pedagogia, Formação de Professores, Educação', 4),
('Economia e Gestão', 'Economia, Administração, Contabilidade, Gestão', 5),
('Agricultura e Recursos Naturais', 'Agronomia, Florestas, Pescas, Ambiente', 6),
('Tecnologias de Informação', 'Informática, Programação, Redes, Sistemas', 7),
('Artes e Design', 'Artes Visuais, Música, Teatro, Design', 8),
('Hotelaria e Turismo', 'Gestão Hoteleira, Turismo, Restauração', 9);

-- Inserir configurações do sistema
INSERT INTO configuracoes_sistema (chave, valor, tipo, descricao, categoria) VALUES
('nome_sistema', 'Sistema de Orientação Vocacional - Escola Eduardo Mondlane', 'string', 'Nome do sistema', 'geral'),
('ano_lectivo', '2025', 'int', 'Ano lectivo atual', 'geral'),
('limite_recomendacoes', '10', 'int', 'Número máximo de recomendações por estudante', 'recomendacao'),
('tempo_sessao_horas', '2', 'int', 'Duração da sessão em horas', 'seguranca'),
('email_contato', 'orientacao@eduardomondlane.edu.mz', 'string', 'Email de contacto do sistema', 'comunicacao'),
('ativa_registro_estudantes', 'true', 'boolean', 'Permitir registro de novos estudantes', 'registro'),
('manutencao_sistema', 'false', 'boolean', 'Modo de manutenção do sistema', 'geral');

-- Inserir administrador padrão (senha: Admin@2025)
INSERT INTO usuarios (nome, email, senha, tipo, status) VALUES
('Administrador Sistema', 'admin@orientacao.mz', '$2y$10$YourHashHere', 'administrador', 'ativo');

-- Inserir dados do administrador
INSERT INTO administradores (id, nivel_acesso, departamento, cargo) 
SELECT LAST_INSERT_ID(), 'super', 'Tecnologias de Informação', 'Administrador do Sistema';

-- ============================================
-- ÍNDICES ADICIONAIS PARA PERFORMANCE
-- ============================================

-- Índices para consultas frequentes
CREATE INDEX idx_respostas_data ON respostas_estudantes(estudante_id, data_resposta);
CREATE INDEX idx_recomendacoes_afinidade ON recomendacoes_cursos(estudante_id, pontuacao_afinidade DESC);
CREATE INDEX idx_cursos_area ON cursos(area_formacao_id, tipo_curso);
CREATE INDEX idx_logs_tipo ON logs_acesso(tipo_usuario, data_hora);
CREATE INDEX idx_estudantes_classe_turma ON estudantes(classe, turma, ano_lectivo);
