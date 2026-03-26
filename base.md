/**
 * @module TemplateName
 * @description Briefly describe what this module does.
 * @note Built using the Atassa Bulletproof Framework architecture.
 */

// ==============================================================================
// 1. DYNAMIC REGISTRAR (Do not modify)
// Automatically maps the correct command loader regardless of the bot fork.
// ==============================================================================
let commandRegister;
try {
    const cmdSys = require('../gift/gmdCmds');
    commandRegister = cmdSys.gifted || cmdSys.gmd || cmdSys.cmd || cmdSys.smd || cmdSys.Module || cmdSys;
} catch (err) {
    console.error("[Module Alert] Could not load the command system: ", err.message);
}

// ==============================================================================
// 2. CORE UTILITIES (Do not modify)
// These prevent Baileys crashes and hunt for correct framework parameters.
// ==============================================================================

/**
 * Deep Argument Hunter: Finds the true socket and message object.
 */
const resolveContext = (arg1, args) => {
    let sock = global.conn || global.client || arg1.bot || arg1.client;
    let m = arg1;
    const allArgs = [arg1, ...args];
    allArgs.forEach(arg => {
        if (arg && typeof arg === 'object' && !Array.isArray(arg)) {
            // Find Socket
            if (typeof arg.sendMessage === 'function') sock = arg;
            else if (arg.sock && typeof arg.sock.sendMessage === 'function') sock = arg.sock;
            else if (arg.bot && typeof arg.bot.sendMessage === 'function') sock = arg.bot;
            // Find Message
            if (arg.chat || arg.from || arg.jid || (arg.key && arg.key.remoteJid)) m = arg;
        }
    });
    return { m, sock };
};

/**
 * Deep Quote Sanitizer: Prevents Baileys `jidDecode` and `fromMe` crashes.
 */
const buildSafeQuote = (m) => {
    if (!m || !m.key || !m.key.remoteJid || !m.key.id) return {};
    const cleanKey = {
        remoteJid: String(m.key.remoteJid),
        fromMe: Boolean(m.key.fromMe),
        id: String(m.key.id)
    };
    if (m.key.participant) cleanKey.participant = String(m.key.participant);
    return { quoted: { key: cleanKey, message: m.message || {} } };
};

// ==============================================================================
// 3. CORE LOGIC (Write your custom feature here!)
// ==============================================================================
const executeMyFeature = async (m, sock, customParam) => {
    try {
        // 1. Resolve Chat ID safely
        const rawChatId = m.chat || m.from || m.jid || (m.key && m.key.remoteJid) || m.sender;
        const chatId = typeof rawChatId === 'string' ? rawChatId : undefined;
        if (!chatId) return;

        // 2. Build Safe Quote
        const sendOptions = buildSafeQuote(m);

        // 3. Your Custom Logic Here (e.g., fetching an API, calculating math)
        // Always wrap external requests in try/catch!
        const replyText = `✅ *Success!* You triggered the command with param: ${customParam}`;

        // 4. Send Message (Native Baileys Routing)
        if (sock && typeof sock.sendMessage === 'function') {
            await sock.sendMessage(chatId, { text: replyText }, sendOptions);
        } else if (m && typeof m.reply === 'function') {
            await m.reply(replyText);
        }

    } catch (error) {
        // Never crash the bot. Log and notify gracefully.
        console.error(`[Feature Error] Msg: ${error.message}`);
        if (m && typeof m.reply === 'function') m.reply(`⚠️ *Error:* ${error.message}`);
    }
};

// ==============================================================================
// 4. COMMAND REGISTRATION
// Must use literal strings for the static menu parser. No loops.
// ==============================================================================

if (typeof commandRegister === 'function') {
    
    // Command 1
    commandRegister({ 
        pattern: "mycmd", 
        cmdname: "mycmd", 
        alias: ["mycmd1", "testcmd"], 
        type: "general", // Determines where it goes in the /menu
        category: "general", 
        desc: "Description of what this command does.", 
        react: "⚙️", 
        filename: __filename 
    }, async (arg1, ...args) => { 
        const { m, sock } = resolveContext(arg1, args);
        await executeMyFeature(m, sock, "Parameter1"); 
    });

    // Command 2 (If needed)
    commandRegister({ 
        pattern: "mycmd2", 
        cmdname: "mycmd2", 
        alias: ["mycmd2"], 
        type: "general", 
        category: "general", 
        desc: "Another command in this file.", 
        react: "⚙️", 
        filename: __filename 
    }, async (arg1, ...args) => { 
        const { m, sock } = resolveContext(arg1, args);
        await executeMyFeature(m, sock, "Parameter2"); 
    });

} else {
    console.error("❌ CRITICAL: Module failed to map the command registration function.");
}
