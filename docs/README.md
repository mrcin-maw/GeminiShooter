# GitHub Pages - Gemini Shooter Presentation

This directory contains the GitHub Pages website for the Gemini Shooter project.

## Viewing the Site

Once GitHub Pages is enabled, the site will be available at:
`https://mrcin-maw.github.io/GeminiShooter/`

## Enabling GitHub Pages

To enable GitHub Pages for this repository:

1. Go to repository Settings
2. Navigate to "Pages" in the left sidebar
3. Under "Source", select:
   - **Source**: Deploy from a branch
   - **Branch**: `copilot/create-atari-game-in-madpascal` (or main branch after merge)
   - **Folder**: `/docs`
4. Click "Save"
5. Wait a few minutes for the site to deploy

## Local Testing

To test the site locally, you can use any simple HTTP server:

```bash
# Using Python
cd docs
python3 -m http.server 8000

# Using Node.js
npx http-server docs -p 8000

# Then open http://localhost:8000 in your browser
```

## Features

The presentation page includes:

- 🌐 Bilingual support (Polish and English)
- 🎮 Game description and features
- 📥 Direct download link for GeminiShooter.xex
- 🕹️ Controls and gameplay instructions
- 🔧 Technical specifications
- 🛠️ Build instructions
- 📚 Credits and references
- ⭐ Animated star background for space theme

## Customization

The page is fully self-contained in `index.html` with embedded CSS and JavaScript.
All styling and animations are responsive and work on mobile devices.

## File Structure

```
docs/
  ├── index.html           # Main presentation page (Polish)
  ├── index-en.html        # English version
  ├── GeminiShooter.xex    # Game binary for download
  └── README.md            # This file
```

The game XEX file is included directly in the docs folder for GitHub Pages access.
