# موعد — ارسال به GitHub و تست APK روی موبایل

این بسته برای تست نسخه 1.0.0 روی Android آماده شده است.

## مشخصات
- Application ID: `ir.wearepulse.moed`
- App name: `موعد`
- Version: `1.0.0+1`
- minSdk: 24
- targetSdk / compileSdk: 36
- Java: 17
- CI: GitHub Actions

## اولین Push
```bash
git init
git add .
git commit -m "Moed v1 mobile test"
git branch -M main
git remote add origin YOUR_GITHUB_REPOSITORY_URL
git push -u origin main
```

بعد از Push، Workflow با نام **Android Test Build** خودکار اجرا می‌شود.
از تب **Actions** وارد اجرای موفق شوید و Artifact با نام `moed-v1-test-apk` را دانلود کنید.
داخل فایل Artifact، `app-release.apk` را روی گوشی Android نصب کنید.

> Workflow عادی برای تست موبایل از signing آزمایشی Flutter استفاده می‌کند و برای انتشار در مارکت نیست.
> Workflow «Android Signed Release» فقط بعد از ساخت keystore و تعریف GitHub Secrets اجرا شود.
