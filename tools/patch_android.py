import glob
import os
import re

path = "android/app/src/main/AndroidManifest.xml"
with open(path, "r", encoding="utf-8") as f:
    xml = f.read()

perms = [
    "android.permission.INTERNET",
    "android.permission.CAMERA",
    "android.permission.RECORD_AUDIO",
    "android.permission.MODIFY_AUDIO_SETTINGS",
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.ACCESS_WIFI_STATE",
    "android.permission.BLUETOOTH",
    "android.permission.BLUETOOTH_CONNECT",
]

add = ""
for p in perms:
    if p not in xml:
        add += f'    <uses-permission android:name="{p}" />\n'

if 'android.hardware.camera"' not in xml:
    add += '    <uses-feature android:name="android.hardware.camera" android:required="false" />\n'
    add += '    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />\n'

if add:
    xml = xml.replace("<application", add + "    <application", 1)

xml = re.sub(r'android:label="[^"]*"', 'android:label="Video Test"', xml, count=1)

with open(path, "w", encoding="utf-8") as f:
    f.write(xml)
print("Manifest patched")

# --- compileSdk fix -------------------------------------------------------
# Plugins (agora_rtc_engine, iris_method_channel, permission_handler_android)
# and their AndroidX dependencies require compileSdk 37, while the app module
# and old plugins default to 36 / 31. A Gradle init script forces compileSdk 37
# on EVERY module (app + all plugins) right after it is evaluated.
COMPILE_SDK = 37
init_dir = os.path.join(os.path.expanduser("~"), ".gradle", "init.d")
os.makedirs(init_dir, exist_ok=True)
init_script = f"""allprojects {{
    afterEvaluate {{ p ->
        if (p.extensions.findByName('android') != null) {{
            p.extensions.android.compileSdkVersion {COMPILE_SDK}
        }}
    }}
}}
"""
with open(os.path.join(init_dir, "compile-sdk.gradle"), "w", encoding="utf-8") as f:
    f.write(init_script)
print(f"Gradle init script written: all modules -> compileSdk {COMPILE_SDK}")

# --- APK size fix -----------------------------------------------------------
# Fat APK me armeabi-v7a + arm64-v8a + x86_64 teeno native libs aate hain
# (Agora bahut bhari hai). x86_64 sirf emulator ke liye hota hai, isliye hata do.
# Sirf naye 64-bit phones ke liye aur chhoti APK chahiye to list me se
# "armeabi-v7a" hata do.
ABIS = ["armeabi-v7a", "arm64-v8a"]

gradle_files = glob.glob("android/app/build.gradle.kts") + glob.glob("android/app/build.gradle")
if not gradle_files:
    print("WARNING: android/app/build.gradle(.kts) nahi mila, ABI filter skip")
else:
    gf = gradle_files[0]
    with open(gf, "r", encoding="utf-8") as f:
        src = f.read()
    if "abiFilters" in src:
        print("abiFilters pehle se hai, skip")
    else:
        m = re.search(r"defaultConfig\s*\{", src)
        if not m:
            print("WARNING: defaultConfig block nahi mila, ABI filter skip")
        else:
            if gf.endswith(".kts"):
                abis = ", ".join(f'"{a}"' for a in ABIS)
                snippet = f"\n        ndk {{ abiFilters.addAll(listOf({abis})) }}\n"
            else:
                abis = ", ".join(f"'{a}'" for a in ABIS)
                snippet = f"\n        ndk {{ abiFilters {abis} }}\n"
            src = src[: m.end()] + snippet + src[m.end():]
            with open(gf, "w", encoding="utf-8") as f:
                f.write(src)
            print(f"ABI filter added in {gf}: {ABIS}")
