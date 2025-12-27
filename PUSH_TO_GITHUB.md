# Push to GitHub Instructions

Your local repository is ready! Now you need to:

## 1. Create GitHub Repository

Go to: https://github.com/new
- Repository name: `qbittest`
- Description: `qBittorrent Home Assistant Add-on with WireGuard fixes`
- Set to **Public** (required for HA add-on repositories)
- **DO NOT** check "Add a README file" (we already have one)
- Click **Create repository**

## 2. Push Your Local Repository

After creating the GitHub repository, run these commands:

```bash
# Add your GitHub repository as remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/qbittest.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## 3. Add to Home Assistant

Once pushed to GitHub:

1. **Supervisor → Add-on Store**
2. **Click ⋮ (three dots) → Repositories**
3. **Add**: `https://github.com/YOUR_USERNAME/qbittest`
4. **Refresh** the add-on store
5. **Install** "qBittorrent (Fixed)" version 5.1.4-5

## Your Repository URL

After creating on GitHub, your repository will be:
`https://github.com/YOUR_USERNAME/qbittest`

## What's Included

✅ **repository.yaml** - Makes it a valid HA add-on repository
✅ **README.md** - Repository documentation
✅ **qbittorrent/** - Fixed add-on with extended WireGuard timeout
✅ **Version 5.1.4-5** - Higher than original (5.1.4-4)

## Expected Results

After installation, WireGuard connections will:
- Get 130 seconds to establish (vs 25 seconds original)
- Show better validation and error messages
- Actually work reliably!

Replace YOUR_USERNAME with your actual GitHub username in the commands above.