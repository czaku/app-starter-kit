# Sentinel

Sentinel is the source of truth for cross-platform consistency: design tokens, strings, feature flags, models, API endpoints, and the screen catalog.

**Adherence to this guide is required.**

---

## Before Every Task

```bash
npx sentinel schema:validate
```

If validation fails, stop and fix schema errors before proceeding.

---

## Schema Workflow

Edit schemas in the `sentinel/` directory. After any schema change:

```bash
npx sentinel schema:generate
```

**Never hand-edit generated output files.** They are listed in `sentinel.yaml → platforms[*].output`. Edit the schema, then regenerate.

---

## Screen Catalog

The catalog is a collection of screenshots for every screen, OS version, device type, and visual variant declared in `sentinel.yaml`.

### Configuration (`sentinel.yaml`)

```yaml
catalog:
  output: catalog/
  resize: 1000

  ios18:
    iphone:
      slug: myapp-ios
      app_id: com.example.app
    # ipad:
    #   slug: myapp-ipad
    #   app_id: com.example.app

  ios26:
    iphone:
      slug: myapp-ios26
      app_id: com.example.app
      glossy: true        # also captures glossy-light + glossy-dark variants

  android:
    phone:
      slug: myapp-android
      app_id: com.example.app

  screens:
    - slug: sign-in
      name: Sign In
      flow: flows/sign-in.yaml
    - slug: home
      name: Home
      flow: flows/home.yaml
      scrolls: 2           # captures scroll1, scroll2 in addition to base
    - slug: profile
      name: Profile
      # no flow — use catalog:upload for manual screenshots
```

### Filename Convention

```
{screen}-{os}-{device}-{variant}[-scroll{N}].png
```

Examples:
- `sign-in-ios18-iphone-light.png`
- `sign-in-ios18-iphone-dark.png`
- `home-ios26-iphone-glossy-light.png`
- `home-android-phone-dark-scroll2.png`

Supported OS keys: `ios18`, `ios26`, `android`, `watchos`, `tvos`
Supported device types: `iphone`, `ipad`, `watch`, `phone`, `tablet`, `tv`
Supported variants: `light`, `dark`, `glossy-light`, `glossy-dark`

### Commands

**Capture all screenshots** (requires Maestro flows):
```bash
npx sentinel catalog:capture
```

Filter by OS or device:
```bash
npx sentinel catalog:capture --os ios18
npx sentinel catalog:capture --os android --device phone
```

**Upload a single screenshot manually** (for screens without a Maestro flow):
```bash
npx sentinel catalog:upload --screen sign-in --os ios18 --device iphone --variant light /tmp/screenshot.png
```

If a screenshot already exists at that path, it is replaced.

**Validate** all expected screenshots exist:
```bash
npx sentinel catalog:validate
```

**Generate the HTML catalog**:
```bash
npx sentinel catalog:index
```

**Open the catalog**:
```bash
open catalog/index.html
```

### Rules

- **Never create your own HTML screen viewer.** `sentinel catalog:index` is the only permitted way to view the catalog.
- Never commit hand-crafted screenshot HTML, base64-embedded images, or custom catalog viewers of any kind.
- Screens without a Maestro `flow` cannot use `catalog:capture` — use `catalog:upload` instead.
- After adding a new screen to `sentinel.yaml`, capture or upload all required variants before considering the task done.
- After capture, run `catalog:validate` to confirm no variants are missing.
