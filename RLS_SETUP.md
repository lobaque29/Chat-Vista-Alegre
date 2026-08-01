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
