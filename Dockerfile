# 1. Temel imaj olarak Python 3.9 slim sürümünü kullanıyoruz.
FROM python:3.9-slim

# 2. Sistem paketlerini güncelliyoruz ve wget, gnupg2, curl gibi gerekli araçları yüklüyoruz.
RUN apt-get update && apt-get install -y wget gnupg2 curl

# 3. Google Chrome’un GPG anahtarını ekliyoruz ve repository kaynağı oluşturuyoruz.
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable

# 4. Çalışma dizinimizi belirliyoruz.
WORKDIR /app

# 5. Öncelikle requirements.txt dosyasını container'a kopyalıyoruz ve bağımlılıkları yüklüyoruz.
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && pip install -r requirements.txt

# 6. Projenizin tüm dosyalarını container'a kopyalıyoruz.
COPY . /app

# 7. (Opsiyonel) Eğer uygulamanızın belirli bir portu varsa bu portu açabilirsiniz.
# EXPOSE 8000

# 8. Container başlatıldığında çalışacak komutu belirtiyoruz. Bu örnekte main.py dosyasını çalıştırıyoruz.
CMD ["python", "main.py"]
