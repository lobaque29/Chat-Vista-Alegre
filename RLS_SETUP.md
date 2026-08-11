# Configuração do Supabase para Chat Vista Alegre (com autenticação anônima)

Este projeto autentica no Supabase automaticamente com usuário anônimo (Supabase Auth). Esse usuário entra com role `authenticated`.

## Passo único (recomendado)

1. Abra o SQL Editor do projeto:
https://supabase.com/dashboard/project/ujlxgjaqklfxgiigzkid/sql/new

2. Antes de rodar o SQL, ative o provider anônimo em Authentication > Providers > Anonymous Sign-Ins.

3. Cole e execute o conteúdo de [supabase-setup.sql](supabase-setup.sql).

4. Recarregue o chat.

## O que esse setup faz

- Cria tabela `public.chat_messages` (se não existir)
- Habilita RLS
- Permite `SELECT` e `INSERT` para role `authenticated` (inclui login anônimo)
- Bloqueia `UPDATE` e `DELETE` por padrão (mais seguro)
- Cria bucket `chat-audios` público (se não existir)
- Cria políticas de `SELECT` e `INSERT` no storage para `chat-audios`
- Ativa `REPLICA IDENTITY FULL` para realtime da tabela

## Verificação rápida

No console do navegador (F12), você deve ver logs como:

- `[DEBUG] Carregadas X mensagens iniciais`
- `[DEBUG] Mensagem salva no banco com sucesso`

Se aparecer `Banco indisponível no Supabase`, o SQL não foi aplicado completo ou foi aplicado em outro projeto.

## Observação de segurança

Com login anônimo, já existe identidade de sessão no Supabase, mas sem verificação de e-mail/telefone. Se quiser identidade forte por pessoa, o próximo passo é migrar para e-mail/senha ou OAuth.

## Checklist de validação em produção

Rode estes testes após publicar para confirmar segurança e estabilidade:

1. Mensagem em tempo real
- Abra o chat em 2 navegadores/dispositivos.
- Envie mensagem no dispositivo A e valide entrega imediata no dispositivo B.

2. Presença online
- Entre com 2 sessões e confirme contagem de pessoas online.
- Feche uma sessão e valide queda da contagem em poucos segundos.

3. RLS de escrita
- Envie mensagem normal e confirme sucesso.
- No SQL Editor, valide que `user_id` gravado bate com `auth.uid()` do usuário anônimo da sessão.

4. Storage restrito por usuário
- Faça upload de áudio/arquivo e confirme sucesso.
- Tente forçar upload para caminho com UID diferente do usuário atual e confirme bloqueio por policy.

5. Integridade do histórico
- Recarregue a página e confirme histórico carregando do banco.
- Verifique no console se não há spam de erro de polling/realtime.

6. Falha controlada
- Desative temporariamente a tabela ou policy de insert para simular erro.
- Confirme que o app mostra alerta ao usuário e não quebra a interface.

## Consultas úteis no Supabase SQL Editor

Use estas consultas para inspeção rápida:

```sql
-- Últimas mensagens gravadas
select id, created_at, user_id, username, type
from public.chat_messages
order by created_at desc
limit 20;

-- Verificar volume por tipo
select type, count(*)
from public.chat_messages
group by type
order by count(*) desc;
```
