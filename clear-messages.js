// Script moderno com fetch nativo (Node.js 18+)
const supabaseUrl = 'https://ujlxgjaqklfxgiigzkid.supabase.co';
const supabaseKey = 'sb_publishable_YT16f9u7iUN6C_-Reo0QoQ_gjlyQZdc';

async function clearAllMessages() {
  console.log('[INFO] Iniciando limpeza do histórico...');
  
  try {
    // Supabase requer uma cláusula WHERE, então usamos id.not.eq.'' (seleciona todas!)
    const response = await fetch(`${supabaseUrl}/rest/v1/chat_messages?id=not.eq.&limit=10000`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`,
        'Prefer': 'return=minimal'
      }
    });

    if (!response.ok) {
      const error = await response.text();
      console.error('[ERROR] Erro ao deletar mensagens:', response.status, error);
      process.exit(1);
    }

    console.log('✅ Todas as mensagens foram deletadas com sucesso!');
    console.log('[INFO] Status: ' + response.status);
    process.exit(0);
  } catch (err) {
    console.error('[ERROR] Exceção:', err.message);
    process.exit(1);
  }
}

clearAllMessages();
