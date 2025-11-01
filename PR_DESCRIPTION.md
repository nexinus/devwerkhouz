# PR: Google Sign-In, Tailwind Config Fix, and ChatGPT-like UI Redesign

## Summary

This PR implements three major improvements:

1. **Google OAuth Sign-In** - Functional Google authentication integrated with Devise
2. **Tailwind Config Fix** - Normalized config and verified build output
3. **UI Redesign** - Modern ChatGPT-like interface for hero, header, footer, and sidebar

## Commits

- `feat(auth): add google oauth sign-in`
- `fix(tailwind): normalize config, safelist & build`
- `feat(ui): redesign hero/header/footer/sidebar (ChatGPT-like)`

## Changes by Task

### Task A — Google Sign-In

**Files Changed:**
- `config/initializers/devise.rb` - Updated OAuth scope to `email,profile`
- `config/initializers/omniauth.rb` - Standardized OAuth configuration
- `app/controllers/users/omniauth_callbacks_controller.rb` - Enhanced error handling
- `app/views/devise/sessions/new.html.erb` - Improved Google button styling

**Key Changes:**
- Scope changed from `userinfo.email, userinfo.profile` to `email,profile` (per requirements)
- Added comprehensive error handling with friendly user messages
- Improved button accessibility with focus states and ARIA labels
- Set `seen_welcome` flag on first OAuth login
- Redirect to sign-in page on authentication failure (not root)

**Environment Variables Required:**
```bash
# Local (.env.development - not committed)
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here

# Or use Rails credentials (production)
# rails credentials:edit
# Add:
# google:
#   client_id: your_client_id_here
#   client_secret: your_client_secret_here
```

**OAuth Callback URLs to Configure in Google Cloud Console:**
- Dev: `http://localhost:3000/users/auth/google_oauth2/callback`
- Prod: `https://devwerkhouz.onrender.com/users/auth/google_oauth2/callback`

### Task B — Tailwind Config Fix

**Files Changed:**
- `tailwind.config.js` - Cleaned content paths, organized safelist

**Key Changes:**
- Removed unnecessary content paths (kept only required: views, helpers, javascript, builds)
- Organized safelist with comments
- Verified all required classes are safelisted:
  - `bg-accent-orange`, `bg-accent-orange-dark`, `hover:bg-accent-orange-dark`
  - `shadow-orange-soft`, `shadow-orange-strong`
  - `text-neutral-700`, `text-neutral-600`, `bg-neutral-50`, `bg-neutral-100`
- Build verified: `bin/rails tailwindcss:build` succeeds

**Theme Configuration Verified:**
- `colors.brand`: `#819231`
- `colors.accent.orange`: `#FF7A18`
- `colors.accent.orange-dark`: `#E65A00`
- `colors.neutral`: Full palette (50-800)
- `boxShadow.orange-soft`, `orange-strong`: Defined with correct rgba values

### Task C — UI Redesign (ChatGPT-like)

**Files Changed:**
- `app/views/shared/_header.html.erb` - Complete redesign
- `app/views/shared/_sidebar.html.erb` - Complete redesign
- `app/views/shared/_footer.html.erb` - Minimal, subtle design
- `app/views/pages/_hero.html.erb` - Centered composer card
- `app/views/layouts/application.html.erb` - Updated layout structure

**Header:**
- Fixed to top (`fixed top-0`) with subtle shadow
- Logo on left, user avatar (initials) + dropdown on right
- Mobile hamburger toggles sidebar
- Accessible dropdown with keyboard navigation
- Uses project colors (accent-orange for CTAs)

**Sidebar:**
- Collapsible: `w-64` (open) / `w-16` (closed)
- Navigation items: Dashboard, Prompts, Saved, Settings
- Icons + labels (labels hide when collapsed)
- Fixed positioning, responsive (hidden on mobile by default)
- New prompt button with accent-orange styling and shadow
- Smooth transitions

**Hero:**
- Centered composer card with large textarea (`min-h-[200px]`)
- ChatGPT-like minimal design
- Focus states on inputs
- Turbo frame integration for generated prompts
- Benefits grid below composer (4-column responsive)

**Footer:**
- Subtle, minimal design
- Links to Privacy, Terms, Impressum
- Accessible with focus rings

**Layout:**
- Fixed header with `pt-14` offset on body
- Sidebar and main content margins adjust on collapse
- Smooth transitions (`transition-all duration-200`)

## Verification Steps

### 1. Google Sign-In Verification

```bash
# Check routes
bin/rails routes | grep google

# Expected output should include:
# user_google_oauth2_omniauth_authorize GET /users/auth/google_oauth2
# user_google_oauth2_omniauth_callback  GET /users/auth/google_oauth2/callback
```

**Manual Steps:**
1. Set `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` in `.env.development`
2. Start server: `bin/dev`
3. Visit `/users/sign_in`
4. Click "Sign in with Google" button
5. Complete OAuth flow
6. Verify redirect to dashboard and `current_user` is set
7. Check server logs for successful callback

### 2. Tailwind Build Verification

```bash
# Clean and rebuild
bin/rails assets:clobber
RAILS_ENV=development bin/rails tailwindcss:build

# Verify output file exists
ls -la app/assets/builds/tailwind.css

# Check for custom colors (may need to check CSS directly)
grep -n "accent-orange" app/assets/builds/tailwind.css | head -5
grep -n "shadow-orange-soft" app/assets/builds/tailwind.css | head -3
```

**Expected:** Build succeeds, `tailwind.css` contains custom classes

### 3. UI Verification

**Visual Checks:**
1. Header: Fixed to top, logo left, avatar right (when signed in)
2. Sidebar: Collapsible, navigation items visible, icons + labels
3. Hero: Centered composer card with large textarea
4. Footer: Subtle, links visible

**Responsive Checks:**
1. Resize viewport to mobile (< 768px): Sidebar should be hidden
2. Toggle sidebar: Should collapse to icons-only
3. Mobile hamburger: Should toggle sidebar visibility

**Accessibility Checks:**
1. Tab through navigation: Focus rings visible
2. Keyboard navigation: Dropdown menu accessible
3. Screen reader: ARIA labels on buttons and links

**Color Verification:**
- Accent orange buttons: `#FF7A18` background
- Brand green: `#819231` (used in some elements)
- Neutral grays: Used throughout for text/backgrounds

## Deployment Notes

### Environment Variables (Render)

Add these in Render dashboard → Environment:
```
GOOGLE_CLIENT_ID=your_production_client_id
GOOGLE_CLIENT_SECRET=your_production_client_secret
```

### OAuth Redirect URI

Add in Google Cloud Console:
```
https://devwerkhouz.onrender.com/users/auth/google_oauth2/callback
```

### Build Command

No changes needed - standard Rails build process works.

## Testing Checklist

- [x] Google OAuth routes configured correctly
- [x] Tailwind build succeeds
- [x] Custom colors/shadows in safelist
- [x] Header fixed and responsive
- [x] Sidebar collapsible with icons + labels
- [x] Hero composer centered and accessible
- [x] Footer minimal and accessible
- [x] Mobile responsive design
- [x] Keyboard navigation works
- [x] No secrets committed

## Manual Testing Commands

```bash
# 1. Install dependencies
bundle install

# 2. Start dev server
bin/dev

# 3. Check routes
bin/rails routes | grep google

# 4. Verify Tailwind build
RAILS_ENV=development bin/rails tailwindcss:build
ls -la app/assets/builds/tailwind.css

# 5. Test Google sign-in (requires env vars set)
# Visit: http://localhost:3000/users/sign_in
# Click "Sign in with Google"
```

## Known Limitations

- Sidebar JavaScript uses vanilla JS (could be converted to Stimulus controller)
- Dropdown menu uses inline script (could be extracted to Stimulus)
- Mobile sidebar behavior may need refinement based on usage

## Rollback Instructions

If issues arise:

1. **Google Auth**: Remove `config.omniauth` lines from `devise.rb` and `omniauth.rb`
2. **Tailwind**: Restore previous `tailwind.config.js`
3. **UI**: Restore previous view files from `main` branch

## Files Changed Summary

```
config/initializers/devise.rb                     | 6 changes
config/initializers/omniauth.rb                   | 4 changes (new file)
app/controllers/users/omniauth_callbacks_controller.rb | 14 changes
app/views/devise/sessions/new.html.erb            | 7 changes
tailwind.config.js                                | 6 changes
app/views/shared/_header.html.erb                 | 80+ changes (redesign)
app/views/shared/_sidebar.html.erb                | 60+ changes (redesign)
app/views/shared/_footer.html.erb                 | 25+ changes (redesign)
app/views/pages/_hero.html.erb                    | 100+ changes (redesign)
app/views/layouts/application.html.erb            | 40+ changes
```

Total: ~10 files changed, ~350 insertions, ~250 deletions

