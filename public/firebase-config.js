const defaultSupabaseConfig = {
  url: 'COLE_SUPABASE_URL',
  anonKey: 'sb_publishable_YT16f9u7iUN6C_-Reo0QoQ_gjlyQZdc',
  messagesTable: 'chat_messages',
  audioBucket: 'chat-audios',
  roomName: 'chatvista-sala'
};

const REQUIRED_KEYS = ['url', 'anonKey'];

function hasRequiredKeys(config) {
  return REQUIRED_KEYS.every((key) => typeof config[key] === 'string' && config[key].trim().length > 0);
}

function readSupabaseConfigFromLocalStorage() {
  if (typeof window === 'undefined' || !window.localStorage) {
    return null;
  }

  const raw = window.localStorage.getItem('chatvista.supabaseConfig');
  if (!raw) {
    return null;
  }

  try {
    const parsed = JSON.parse(raw);
    if (!parsed || typeof parsed !== 'object' || !hasRequiredKeys(parsed)) {
      return null;
    }

    return {
      url: parsed.url.trim(),
      anonKey: parsed.anonKey.trim(),
      messagesTable: (parsed.messagesTable || defaultSupabaseConfig.messagesTable).trim(),
      audioBucket: (parsed.audioBucket || defaultSupabaseConfig.audioBucket).trim(),
      roomName: (parsed.roomName || defaultSupabaseConfig.roomName).trim()
    };
  } catch {
    return null;
  }
}

export const supabaseConfig = readSupabaseConfigFromLocalStorage() || defaultSupabaseConfig;
