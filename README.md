# Chat Vista Alegre

Chat web com tela inicial e sala em tempo real para múltiplos usuários usando Supabase (plano gratuito).

## O que já está pronto

- Mensagens em tempo real para todos os usuários conectados.
- Contador de usuários online com presença em tempo real.
- Conversa privada entre usuários pelo clique no nome.
- Envio de arquivos (imagem e link de arquivo) no chat.
- Envio de áudio compartilhado (upload no Supabase Storage).
- Histórico local de fallback quando a leitura do banco falha.
- Hardening de frontend (melhorias anti-XSS no DOM).
- Melhorias de acessibilidade e compatibilidade entre navegadores.

## Arquivos principais

- `chatvista.html`: página inicial.
- `SALA.html`: sala de chat (Supabase realtime).
- `firebase-config.js`: configuração do Supabase (nome de arquivo mantido para compatibilidade).
- `public/SALA.html`: versão publicada da sala de chat.
- `public/firebase-config.js`: configuração do Supabase para hosting.
- `vistaalegre.jpg.jpg`: imagem local.

## Configuração Supabase (obrigatório)

1. Crie um projeto em https://supabase.com.
2. Este repositório já vem apontado para o projeto Supabase configurado em `firebase-config.js` e `public/firebase-config.js`.
3. Em SQL Editor, rode exatamente o script oficial do projeto:

- [supabase-setup.sql](supabase-setup.sql)

Esse arquivo já inclui criação de tabela, índices, RLS, políticas de storage e ajustes para realtime.

4. Em Database > Replication (ou Realtime), habilite realtime para a tabela `chat_messages`.
5. Em Storage, confirme que o bucket `chat-audios` existe e está público.
6. Se quiser trocar para outro projeto Supabase, edite `firebase-config.js` e `public/firebase-config.js` ou sobrescreva pelo `localStorage` usando `chatvista.supabaseConfig`.

### Configuração rápida via localStorage (opcional)

Se preferir, você pode configurar sem editar arquivo usando o console do navegador na página `SALA.html`:

```js
localStorage.setItem('chatvista.supabaseConfig', JSON.stringify({
   url: 'SUA_SUPABASE_URL',
   anonKey: 'SUA_SUPABASE_ANON_KEY',
   messagesTable: 'chat_messages',
   audioBucket: 'chat-audios',
   roomName: 'chatvista-sala'
}));
location.reload();
```

Para limpar essa configuração local:

```js
localStorage.removeItem('chatvista.supabaseConfig');
location.reload();
```

## Deploy do front-end

Publique a pasta `public` em qualquer host estático gratuito:

1. Netlify (recomendado)
2. Vercel
3. GitHub Pages

Como o backend está no Supabase, o chat em tempo real funciona normalmente sem Firebase.

## Configurações extras recomendadas

1. EmailJS (formulário de anúncio em `SALA.html`):
   - Configurar Public Key, Service ID e Template ID válidos.
   - A configuração pode ser feita em runtime pelo próprio modal de anúncio (salva no localStorage).

## Publicação

Pode publicar como site estático em GitHub Pages, Netlify ou Vercel.
O backend realtime será fornecido pelo Supabase.

## Publicar hoje com GitHub Pages (rápido)

Este repositório já inclui o workflow [deploy-pages.yml](.github/workflows/deploy-pages.yml), que publica automaticamente a pasta `public` no GitHub Pages.

1. Envie o código atualizado para a branch `main`.
2. No GitHub, abra **Settings > Pages**.
3. Em **Build and deployment**, selecione **Source: GitHub Actions**.
4. Abra a aba **Actions** e acompanhe o workflow **Deploy static site to GitHub Pages**.
5. Ao finalizar, o site ficará em:
   - `https://lobaque29.github.io/Chat-Vista-Alegre/`

### Importante para o chat funcionar

O site sobe sem erro mesmo sem backend, mas o chat em tempo real depende do Supabase estar ativo e com o SQL aplicado.

Use o guia completo em [RLS_SETUP.md](RLS_SETUP.md).

## Checklist de validação em produção

Rode estes testes após publicar para confirmar segurança e estabilidade:

1. Mensagem em tempo real
- Abra o chat em 2 navegadores ou dispositivos.
- Envie mensagem no dispositivo A e valide entrega imediata no dispositivo B.

2. Presença online
- Entre com 2 sessões e confirme a contagem de pessoas online.
- Feche uma sessão e valide a queda da contagem em poucos segundos.

3. RLS de escrita
- Envie mensagem normal e confirme sucesso.
- No SQL Editor, valide que `user_id` gravado bate com `auth.uid()` da sessão anônima.

4. Storage restrito por usuário
- Faça upload de áudio ou arquivo e confirme sucesso.
- Tente forçar upload para caminho com UID diferente e confirme bloqueio por policy.

5. Integridade do histórico
- Recarregue a página e confirme histórico carregando do banco.
- Verifique no console se não há spam de erro de polling/realtime.

6. Falha controlada
- Desative temporariamente a policy de insert para simular erro.
- Confirme que o app mostra alerta ao usuário e não quebra a interface.

## Consultas úteis no Supabase SQL Editor

```sql
select id, created_at, user_id, username, type
from public.chat_messages
order by created_at desc
limit 20;

select type, count(*)
from public.chat_messages
group by type
order by count(*) desc;
```
