# Antigravity IDE WSL Setup Script

One-command automation script to get [Google Antigravity IDE](https://developers.googleblog.com/en/introducing-googles-new-development-environment-antigravity/) working seamlessly with Windows Subsystem for Linux (WSL).

## 🚀 Quick Start

```bash
# Download and run
curl -L https://raw.githubusercontent.com/smaxiso/antigravity-wsl/master/setup-antigravity-wsl.sh | bash
```

Or download and run separately:

```bash
# Download
wget https://raw.githubusercontent.com/smaxiso/antigravity-wsl/master/setup-antigravity-wsl.sh

# Make executable
chmod +x setup-antigravity-wsl.sh

# Run
./setup-antigravity-wsl.sh
```

## ✨ What It Does

The script automatically:

1. ✅ **Creates `agy` symlink** - Launch Antigravity IDE natively from WSL terminal
2. ✅ **Patches Antigravity IDE config** - Uses correct Google remote extension
3. ✅ **Copies helper scripts** - Auto-detects and copies from VS Code
4. ✅ **Enables mirrored networking** - Fixes browser subagent connectivity

## 🔧 Features

* **Dynamic Environment Parsing** - Finds your Windows AppData paths automatically via `%LOCALAPPDATA%` (no username guessing)
* **Whitespace Safety** - Safely handles the new spaced folder structures introduced in Antigravity 2.0
* **Self-Healing** - Includes `antigravity-repair` tool to fix broken host servers automatically
* **Idempotent** - Safe to run multiple times
* **Backups** - Creates `.backup` files before modifying

## 📋 Prerequisites

* Windows 10/11 with WSL 2 installed
* Google Antigravity IDE installed on Windows
* VS Code with WSL extension (optional, for helper scripts)

## 📝 Manual Setup Guide

For a detailed step-by-step guide with explanations, see my blog post:

**[How I Got Google Antigravity IDE Working Perfectly with WSL](https://smaxiso.web.app/blog/google-antigravity-wsl-guide)**

The blog covers:

* Why this setup is needed
* What each step does
* Detailed troubleshooting logs
* Instructions for migrating old user profiles (via the [Reddit migration guide](https://www.reddit.com/r/GeminiAI/comments/1ti01zq/updated_antigravity_now_its_version_20_and_all_my/))

## 🔄 Updates & Maintenance

### Setup broke or Fresh Install failed? (Repair Tool)

Antigravity IDE updates (or fresh installs) often fail to download the internal server properly, leaving behind broken `.tar.gz` files or reverting configuration changes.

If you see errors like:

> `remote-cli/antigravity-ide: not found`
> `Remote Extension host terminated unexpectedly`
> `ERROR 404: Not Found ... failed to download ... .tar.gz`

Run the repair tool from your WSL terminal:

```bash
antigravity-repair
```

Then restart WSL (`wsl --shutdown` in Windows PowerShell) and try `agy .` again.

### Re-running the Setup

The main setup script is completely safe to re-run at any time to re-apply core configuration patches:

```bash
./setup-antigravity-wsl.sh
```

## 🐛 Troubleshooting

**"No Internet Connection in WSL"**
If Antigravity IDE can't download the server, or `curl`/`git` fails, your WSL DNS is likely broken.

1. Check `/etc/resolv.conf`. If it has a dynamic address, replace it with Google DNS:
```bash
# Temporary fix
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
```

2. See the [blog post](https://smaxiso.web.app/blog/google-antigravity-wsl-guide) for the permanent fix involving `/etc/wsl.conf`.

**"Download Error" for Browser Extension**
If the browser subagent fails with a generic error, strictly follow these steps:
1. Manually install the [Antigravity Chrome Extension](https://chromewebstore.google.com/detail/antigravity-browser-exten/eeijfnjmjelapkebgockoeaadonbchdd).
2. Ensure `.wslconfig` has `networkingMode=mirrored`.
3. Restart WSL.

**"agy command not found"**
- Add `~/.local/bin` to your PATH:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

**"Exec format error"**

* This usually means you have a broken symlink pointing directly to the .exe instead of the wrapper script.
* Run `./setup-antigravity-wsl.sh` again to fix it automatically.

## 📜 License

MIT License - feel free to use, modify, and share!

## 👤 Author

**Sumit Kumar** ([@smaxiso](https://github.com/smaxiso))

* 🌐 Portfolio: [smaxiso.web.app](https://smaxiso.web.app)
* 📝 Blog: [smaxiso.web.app/blog](https://smaxiso.web.app/blog)
* 💼 LinkedIn: [linkedin.com/in/smaxiso](https://linkedin.com/in/smaxiso)

## 🙏 Credits

Inspired by [Dazbo's original guide](https://medium.com/google-cloud/working-with-google-antigravity-in-wsl-944c96c949f3) on Medium.

---

**Found this helpful?** ⭐ Star this repo and [share the blog post](https://smaxiso.web.app/blog/google-antigravity-wsl-guide)!
