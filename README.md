# Antigravity WSL Setup Script

One-command automation script to get [Google Antigravity](https://developers.googleblog.com/en/introducing-googles-new-development-environment-antigravity/) working seamlessly with Windows Subsystem for Linux (WSL).

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

1. ✅ **Creates `agy` symlink** - Launch Antigravity from WSL terminal
2. ✅ **Patches Antigravity config** - Uses correct Google remote extension
3. ✅ **Copies helper scripts** - Auto-detects and copies from VS Code
4. ✅ **Enables mirrored networking** - Fixes browser subagent connectivity

## 🔧 Features

- **Auto-detection** - Finds your Windows username automatically
- **Idempotent** - Safe to run multiple times
- **Backups** - Creates `.backup` files before modifying
- **Validation** - Checks prerequisites and verifies patches
- **Colored output** - Easy-to-read progress indicators

## 📋 Prerequisites

- Windows 10/11 with WSL 2 installed
- Google Antigravity installed on Windows
- VS Code with WSL extension (optional, for helper scripts)

## 📝 Manual Setup Guide

For a detailed step-by-step guide with explanations, see my blog post:

**[Getting Google Antigravity to Work with WSL on Windows](https://smaxiso.web.app/blog/google-antigravity-wsl-guide)**

The blog covers:
- Why this setup is needed
- What each step does
- Troubleshooting common issues
- Alternative methods if the script doesn't work

## 🐛 Troubleshooting

**"agy command not found"**
- Add `~/.local/bin` to your PATH:
  ```bash
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
  ```

**"Antigravity not found"**
- Make sure Antigravity is installed on Windows
- Check the installation path: `C:\Users\<USERNAME>\AppData\Local\Programs\Antigravity`

**"Browser subagent fails"**
- Manually install the [Antigravity Chrome Extension](https://chromewebstore.google.com/detail/antigravity-browser-exten/eeijfnjmjelapkebgockoeaadonbchdd)
- Verify mirrored networking is enabled in `.wslconfig`

**"Setup broke after Antigravity update"**
- Simply re-run the script - it's idempotent and will re-apply all patches

## 🔄 After Antigravity Updates

Google Antigravity updates may overwrite the patched configuration. If your setup stops working after an update, just re-run the script:

```bash
./setup-antigravity-wsl.sh
```

## 📜 License

MIT License - feel free to use, modify, and share!

## 👤 Author

**Sumit Kumar** ([@smaxiso](https://github.com/smaxiso))

- 🌐 Portfolio: [smaxiso.web.app](https://smaxiso.web.app)
- 📝 Blog: [smaxiso.web.app/blog](https://smaxiso.web.app/blog)
- 💼 LinkedIn: [linkedin.com/in/smaxiso](https://linkedin.com/in/smaxiso)

## 🙏 Credits

Inspired by [Dazbo's original guide](https://medium.com/google-cloud/working-with-google-antigravity-in-wsl-944c96c949f3) on Medium.

---

**Found this helpful?** ⭐ Star this repo and [share the blog post](https://smaxiso.web.app/blog/google-antigravity-wsl-guide)!
