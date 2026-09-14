from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
gradle = root / 'android/app/build.gradle.kts'
if not gradle.exists():
    raise SystemExit('android/app/build.gradle.kts not found')

s = gradle.read_text(encoding='utf-8')

# SDK levels.
s = re.sub(r'(?m)^\s*compileSdk\s*=\s*.*$', '    compileSdk = 36', s)
s = re.sub(r'(?m)^\s*minSdk\s*=\s*.*$', '        minSdk = 24', s)
s = re.sub(r'(?m)^\s*targetSdk\s*=\s*.*$', '        targetSdk = 36', s)

# Java 17 and core-library desugaring required by flutter_local_notifications 22.x.
if 'compileOptions {' in s:
    s = re.sub(r'(?m)^\s*sourceCompatibility\s*=\s*.*$', '        sourceCompatibility = JavaVersion.VERSION_17', s)
    s = re.sub(r'(?m)^\s*targetCompatibility\s*=\s*.*$', '        targetCompatibility = JavaVersion.VERSION_17', s)
    if 'isCoreLibraryDesugaringEnabled' not in s:
        s = s.replace(
            'compileOptions {',
            'compileOptions {\n        isCoreLibraryDesugaringEnabled = true',
            1,
        )
else:
    marker = '    defaultConfig {'
    block = (
        '    compileOptions {\n'
        '        isCoreLibraryDesugaringEnabled = true\n'
        '        sourceCompatibility = JavaVersion.VERSION_17\n'
        '        targetCompatibility = JavaVersion.VERSION_17\n'
        '    }\n\n'
    )
    if marker not in s:
        raise SystemExit('Could not locate defaultConfig block')
    s = s.replace(marker, block + marker, 1)

# Old Kotlin DSL templates use kotlinOptions; newer Flutter templates already target JVM 17.
if 'kotlinOptions {' in s:
    s = re.sub(
        r'(?m)^\s*jvmTarget\s*=\s*.*$',
        '        jvmTarget = JavaVersion.VERSION_17.toString()',
        s,
    )

# multidex is harmless on modern Android and keeps notification/plugin deps robust.
if 'multiDexEnabled = true' not in s:
    s = s.replace('    defaultConfig {', '    defaultConfig {\n        multiDexEnabled = true', 1)

# Required Android dependencies.
deps = []
if 'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")' not in s:
    deps.append('    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")')
if 'androidx.appcompat:appcompat:' not in s:
    deps.append('    implementation("androidx.appcompat:appcompat:1.7.1")')

if deps:
    if re.search(r'(?m)^dependencies\s*\{', s):
        s = re.sub(
            r'(?m)^dependencies\s*\{',
            'dependencies {\n' + '\n'.join(deps),
            s,
            count=1,
        )
    else:
        s += '\n\ndependencies {\n' + '\n'.join(deps) + '\n}\n'

gradle.write_text(s, encoding='utf-8')

# local_auth requires LaunchTheme to inherit from a Theme.AppCompat theme.
for styles in [
    root / 'android/app/src/main/res/values/styles.xml',
    root / 'android/app/src/main/res/values-night/styles.xml',
]:
    if not styles.exists():
        continue
    t = styles.read_text(encoding='utf-8')
    t = re.sub(
        r'(<style\s+name="LaunchTheme"\s+parent=")[^"]+("[^>]*>)',
        r'\1Theme.AppCompat.DayNight.NoActionBar\2',
        t,
        count=1,
    )
    styles.write_text(t, encoding='utf-8')

print('Android configuration patched: API 36, minSdk 24, Java 17, desugaring, AppCompat LaunchTheme.')
