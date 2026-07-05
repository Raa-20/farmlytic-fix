const { Client, LocalAuth } = require("whatsapp-web.js");
const qrcode = require("qrcode-terminal");
const axios = require("axios");
const client = new Client({
  authStrategy: new LocalAuth({ clientId: "LADENTRA_BOT" }),
  puppeteer: {
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
  },
});

client.on("qr", (qr) => {
  console.log("\n=========================================");
  console.log("✅ SILAKAN SCAN QR CODE DI BAWAH INI:");
  console.log("=========================================\n");
  qrcode.generate(qr, { small: true });
});

client.on("ready", () => {
  console.log("\n✅ Bot WhatsApp Ladentra AI Siap dan Berjalan!");
});

client.on("message", async (message) => {
  let teks = message.body.trim();
  let audioB64 = null;

  if (message.hasMedia) {
    const media = await message.downloadMedia();
    if (media.mimetype && media.mimetype.includes("audio")) {
      audioB64 = media.data; 
    }
  }

  if (!teks && !audioB64) return;

  await message.reply("🤖 Ladentra AI sedang memproses...");

  try {
    const response = await axios.post(
      "https://api-farmlytics.tifpsdku.com/api/wa-webhook",
      {
        sender: message.from,
        raw_text: teks,
        audio_b64: audioB64, 
      },
      { timeout: 60000 },
    );

    if (response.data.status === "success") {
      await message.reply(response.data.reply);
    } else {
      await message.reply("❌ Gagal: " + response.data.message);
    }
  } catch (error) {
    console.log("❌ ERROR:", error.message);
    await message.reply("❌ Server Ladentra tidak dapat dihubungi.");
  }
});

client.initialize();
