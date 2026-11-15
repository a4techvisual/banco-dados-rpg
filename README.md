[README.md](https://github.com/user-attachments/files/34864945/README.md)
# Avaliação 4 — Segurança da Informação (SQL Server)

Atividade do SENAI — **Desafio 3** (jogo de RPG online).
Disponibilizar somente a visualização dos dados para um usuário restrito e
aplicar o recurso do **SQL Server Audit** para criar uma auditoria.

## Conteúdo

- `avaliacao4_permissao_auditoria.sql` — script com as duas partes da atividade.

## O que o script faz

### Parte 1 — Usuário restrito (somente leitura)
- Cria um **login** com senha.
- Cria o **usuário** no banco ligado a esse login.
- Concede apenas `GRANT SELECT` — o usuário consulta os dados, mas não pode
  inserir, atualizar ou excluir.

### Parte 2 — Auditoria (SQL Server Audit)
- Cria uma **Server Audit** gravando em arquivo (`C:\AuditoriaExemplo`,
  100 MB, substituição ilimitada, atraso de fila de 1000 ms).
- Cria uma **Database Audit Specification** que registra todo `SELECT`
  feito pelo usuário restrito na tabela monitorada.
- Habilita a auditoria e a especificação.

## Como usar

1. Abra o script no **SQL Server Management Studio (SSMS)**.
2. Troque os nomes de exemplo pelos do seu banco:
   - `RpgOnlineDB` → nome do seu banco de RPG
   - `Personagens` → tabela que o usuário poderá consultar
   - `jogador` → usuário restrito a ser criado
3. Crie a pasta `C:\AuditoriaExemplo` no Windows (destino da auditoria).
4. Execute o script.

## Como testar

Conecte no SSMS com o login `jogador` e rode:

```sql
SELECT * FROM Personagens;                 -- permitido (leitura)
INSERT INTO Personagens VALUES ('Teste');  -- bloqueado (prova da restrição)
```

Depois, em **Segurança → Auditorias → AuditoriaRPG → Exibir Logs de
Auditoria**, cada `SELECT` feito pelo usuário aparece registrado no log.

---

**Autor:** Rômulo Delalíbera Júnior
