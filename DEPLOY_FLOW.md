# adnan_ullah
Deploy Flow

## Getting Started

```bash
flutter build web --release
rm -rf docs
mkdir docs
cp -R build/web/* docs/
git add web/index.html docs
git commit -m "Fix base href for GitHub Pages"
git push origin main


Add <base href="/adnan-ullah/"> in web/index.html