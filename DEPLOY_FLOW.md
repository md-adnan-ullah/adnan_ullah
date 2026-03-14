# adnan_ullah
Deploy Flow

## Getting Started

```bash
flutter config --enable-web
flutter build web --release

rm -rf docs
mkdir docs
cp -R build/web/* docs/

git add docs
git commit -m "Add Flutter web build for GitHub Pages"
git push origin main