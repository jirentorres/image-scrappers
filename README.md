# Image-Scrappers Repo
A compilation of image scrapers I developed (for Yandex, Brave, etc.) &amp; gallery-dl and yt-dlp dorks for websites already supported by those projects (boorus, Instagram, TikTok, etc.).

## Required tools:
```sh
curl curl-impersonate aria2c htmlq js-beautify perl sed awk
```
## Dorks
```sh
#devianart
gallery-dl -D ~/Downloads/ --range 1-5 "https://www.deviantart.com/kasanteto/gallery"
gallery-dl -D ~/Downloads/ --range 1-5 "https://www.deviantart.com/search?q=kasane+teto"
#boorus
gallery-dl -D ~/Downloads/ --range 1-5 "https://danbooru.donmai.us/posts?tags=kasane_teto"
#facebook
gallery-dl -D ~/Downloads/ --range 1-5 "https://www.facebook.com/HatsuneMiku/"
#imgur
gallery-dl -D ~/Downloads/ --range 1-5 "https://imgur.com/t/kasane_teto"
#tenor
gallery-dl -D ~/Downloads/ --range 1-5 'https://tenor.com/search/kasane-teto-gifs'
#tiktok
yt-dlp -o "%(title)s.%(ext)s" -P ~/Downloads -N 5 "https://www.tiktok.com/@kasane_teto/"
```
