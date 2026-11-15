/* ============================================================
   AVALIACAO 4 - Seguranca da Informacao (SQL Server)
   Desafio 3 - Jogo de RPG Online
   ------------------------------------------------------------
   Objetivos:
     1) Criar um usuario restrito (somente leitura/consulta)
     2) Aplicar SQL Server Audit para auditar os acessos
   Autor: Romulo Delalibera Junior
   ============================================================

   >>> ANTES DE EXECUTAR, TROQUE OS 3 NOMES ABAIXO: <<<
     - RpgOnlineDB  -> nome do seu banco de RPG
     - Personagens  -> tabela que o usuario podera consultar
     - jogador      -> login/usuario restrito a ser criado
   ============================================================ */


/* ============================================================
   PARTE 1 - USUARIO RESTRITO (SOMENTE LEITURA)
   ============================================================ */
USE RpgOnlineDB;
GO

-- 1. Cria o login com senha (acesso ao SQL Server)
CREATE LOGIN jogador
WITH PASSWORD = 'Senha@1234';
GO

-- 2. Cria o usuario no banco, ligado ao login
CREATE USER jogador FOR LOGIN jogador;
GO

-- 3. Concede SOMENTE leitura (consulta)
GRANT SELECT TO jogador;
GO

/* ------------------------------------------------------------
   TESTE (conecte no SSMS com o login 'jogador' e rode):

   SELECT * FROM Personagens;                 -- permitido (leitura)

   INSERT INTO Personagens VALUES ('Teste');  -- BLOQUEADO
   -- Erro esperado: "A permissao INSERT foi negada no
   -- objeto 'Personagens'..." -> prova do acesso somente leitura
   ------------------------------------------------------------ */


/* ============================================================
   PARTE 2 - SQL SERVER AUDIT (AUDITORIA)
   ------------------------------------------------------------
   OBS: crie antes a pasta  C:\AuditoriaExemplo  no Windows.
   ============================================================ */

-- Passo A: cria a Auditoria no nivel do SERVIDOR (destino = arquivo)
USE master;
GO

CREATE SERVER AUDIT AuditoriaRPG
TO FILE
(
    FILEPATH = 'C:\AuditoriaExemplo',
    MAXSIZE = 100 MB,
    MAX_ROLLOVER_FILES = UNLIMITED
)
WITH
(
    QUEUE_DELAY = 1000,        -- atraso de fila: 1000 ms
    ON_FAILURE = CONTINUE      -- em caso de falha do log: Continuar
);
GO

-- Passo B: habilita a auditoria
ALTER SERVER AUDIT AuditoriaRPG WITH (STATE = ON);
GO

-- Passo C: cria a Especificacao de Auditoria no nivel do BANCO
-- (audita todo SELECT que 'jogador' fizer na tabela 'Personagens')
USE RpgOnlineDB;
GO

CREATE DATABASE AUDIT SPECIFICATION EspecAuditoriaRPG
FOR SERVER AUDIT AuditoriaRPG
ADD (SELECT ON OBJECT::dbo.Personagens BY jogador);
GO

-- Passo D: habilita a especificacao
ALTER DATABASE AUDIT SPECIFICATION EspecAuditoriaRPG WITH (STATE = ON);
GO

/* ------------------------------------------------------------
   COMO VISUALIZAR OS LOGS (no SSMS):
     Seguranca -> Auditorias -> AuditoriaRPG
     -> botao direito -> Exibir Logs de Auditoria

   Conecte como 'jogador', rode alguns SELECT em Personagens
   e atualize o log: cada consulta aparece registrada.
   Um SELECT em outra tabela (nao auditada) NAO aparece no log.
   ------------------------------------------------------------ */
