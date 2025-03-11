import time
import logging
import feedparser
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

# Telegram bot ayarları
TELEGRAM_BOT_TOKEN = "7290235839:AAGGbb-Ubf3aBMIVbiRcgVF5Ig4Sj2s7P8Q"
# Tüm ilanların RSS kaynağı
RSS_FEED_URL = "https://isealimkariyerkapisi.cbiko.gov.tr/UPS/RssXMLs/ilanlar.xml"

# Loglama ayarları
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)
logger = logging.getLogger(__name__)

# Aranacak kelime kombinasyonları
KEYWORDS = [
    "inşaat",
    "mühendis",
    "inşaat mühendisi",
    "mühendislik fakültesi"
]

def fetch_job_detail(driver, url: str) -> str:
    """
    Selenium driver kullanarak, belirtilen URL'deki ilan detay sayfasını getirir.
    Sayfa yüklendiğinde (body etiketinin varlığı) sayfanın HTML içeriğini döndürür.
    """
    try:
        driver.get(url)
        # Sayfa yüklemesinin tamamlanması için body elementini bekle
        WebDriverWait(driver, 20).until(EC.presence_of_element_located(("tag name", "body")))
        # Ekstra bekleme (JavaScript veya dinamik içerik için)
        time.sleep(3)
        return driver.page_source
    except Exception as e:
        logger.error(f"{url} için sayfa içeriği alınırken hata: {e}")
        return ""

async def rss_tarama(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """
    RSS feed'den tüm ilanları çekip, her bir ilan detay sayfasına girer.
    Sayfa içeriğinde tanımlı anahtar kelime kombinasyonlarının varlığı kontrol edilir.
    Eşleşen ilanlar, başlık, link ve eşleşen kelime bilgisiyle birlikte Telegram üzerinden gönderilir.
    """
    await update.message.reply_text("RSS taraması başlatılıyor...")

    try:
        feed = feedparser.parse(RSS_FEED_URL)
    except Exception as e:
        logger.error(f"RSS feed alınırken hata: {e}")
        await update.message.reply_text("RSS feed alınırken hata oluştu.")
        return

    if not feed.entries:
        await update.message.reply_text("RSS feed'inde ilan bulunamadı.")
        return

    found_jobs = []

    # Selenium driver ayarları (headless mod)
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--window-size=1920,1080")
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)

    try:
        for entry in feed.entries:
            title = entry.get("title", "Başlık Yok")
            link = entry.get("link", "")
            if not link:
                continue

            # İlan detay sayfasını çek
            content = fetch_job_detail(driver, link)
            if not content:
                continue

            # Anahtar kelime kontrolü için sayfa içeriğini küçük harfe çeviriyoruz
            content_lower = content.lower()
            matched_keywords = [kw for kw in KEYWORDS if kw.lower() in content_lower]

            if matched_keywords:
                found_jobs.append({
                    "title": title,
                    "link": link,
                    "matched_keywords": matched_keywords
                })
    finally:
        driver.quit()

    if found_jobs:
        message = f"✅ ARAMA TAMAMLANDI! Toplam {len(found_jobs)} adet ilgili ilan bulundu.\n\n"
        for idx, job in enumerate(found_jobs, start=1):
            keywords_str = ", ".join(job["matched_keywords"])
            message += f"{idx}. {job['title']}\n   🔗 {job['link']}\n   ✅ Eşleşen kelimeler: {keywords_str}\n\n"
        await update.message.reply_text(message)
    else:
        await update.message.reply_text("Aradığınız kriterlere uygun ilan bulunamadı.")

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Kullanıcıya başlangıç mesajı gönderir."""
    await update.message.reply_text(
        "Merhaba! RSS tabanlı ilan tarama sistemine hoşgeldiniz. "
        "İlanları taramak için /rss_tarama komutunu kullanabilirsiniz."
    )

def main():
    app = ApplicationBuilder().token(TELEGRAM_BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("rss_tarama", rss_tarama))
    app.run_polling()

if __name__ == "__main__":
    main()
