<p align="center">
  <img alt="Skylus Workspaces Registry" src="./images/Skylus Workspaces Registry Logo.png" width="560">
</p>

# Skylus Harbor Registry

**Skylus Harbor Registry** is the official registry and workspace storefront for **Skylus Workspaces** by **Netweb Technologies India Ltd.**  
It provides a single source of truth for workspace definitions and assets. The site and backend operate in auto‑mode: when you commit workspace definitions or assets to this repository, the storefront and delivery pipeline stay in sync automatically.

---

## Contents

1. About the platform  
2. Getting started  
3. Repository layout  
4. Site configuration  
5. Defining workspaces (authoring guide)  
6. Versioning & channels  
7. Publishing & consumption  
8. Maintenance guidelines  
9. Operational notes  
10. FAQ  
11. Ownership

---

## 1) About the platform

- **Purpose**: Catalog, brand, and deliver containerized workspaces for Skylus Workspaces.  
- **Automation**: Commits trigger the build and update flow; images/files are reflected in the storefront and delivery without manual steps.  
- **Consistency**: JSON schemas, naming, and images follow a single, documented convention.  
- **Security**: You control which images and tags are exposed to users, including GPU variants and privileged configurations where needed.


<p align="left">
  <img alt="Skylus Workspaces Registry" src="./images/Skylus Workspaces Marketplace.png" width="1000">
</p>


---

## 2) Getting started

- Create a repository from this structure or clone it to your organization.  
- Make an initial commit to verify that the site and backend pipeline are healthy.  
- Add workspaces under the `workspaces/` folder and commit changes; the storefront will reflect updates automatically.

> Tip: Use concise names, clean icons, and accurate metadata to ensure a polished marketplace experience.

---

## 3) Repository layout

<p align="left">
  <img alt="Skylus Workspaces Registry" src="./images/Skylus Workspaces Github Repo.png" width="1000">
</p>

```
.
├─ site/                 # Website configuration and assets
├─ processing/           # Optional helper scripts for bulk updates
├─ workspaces/           # Workspace definitions (one folder per workspace)
│  └─ <Workspace Name>/
│     ├─ workspace.json  # Workspace metadata & compatibility
│     └─ icon.png|svg    # Workspace icon (50x50px or larger, square recommended)
└─ README.md
```

- **workspaces/** is the authoritative catalog.  
- Each workspace has **its own folder** with a `workspace.json` and an icon.  
- Filenames should be simple and descriptive.

---

## 4) Site configuration

Configure your storefront by editing `site/next.config.js`:

- `env.name` — Display name shown on the storefront.  
- `env.description` — Short description of your registry.  
- `env.icon` — Path to your logo/icon within `/site/public/` (use the provided Skylus artwork).  
- `env.listUrl` — Root URL of your storefront (string value in config).  
- `env.contactUrl` — Contact route for users (string value in config).  
- `basePath` — Keep `/1.0` unless you need a different default; branch names map to versions automatically.

Commit your changes to trigger a site build.

---

## 5) Defining workspaces (authoring guide)

All workspace definitions are JSON files named `workspace.json` placed under `workspaces/<Workspace Name>/`.

<p align="left">
  <img alt="Skylus Workspaces Registry" src="./images/Skylus Workspaces Github Editing JSON.png" width="1000">
</p>


### 5.1 Folder structure

```
workspaces/
 └─ <Workspace Name>/
     ├─ workspace.json
     └─ workspace-name.png  # or .svg
```

### 5.2 JSON schema (v1.1)

| Property                | Req | Type    | Description |
|-------------------------|:---:|---------|-------------|
| `friendly_name`         | ✓   | String  | Display name for the workspace |
| `description`           | ✓   | String  | Short description shown on the card/details |
| `image_src`             | ✓   | String  | Icon filename (e.g., `chrome.png`) |
| `architecture`          | ✓   | Array   | One or both of `amd64`, `arm64` |
| `compatibility`         | ✓   | Array   | Objects mapping platform versions to images/tags/sizes |
| `categories`            |     | Array   | Up to 3 categories (e.g., Browser, Development) |
| `docker_registry`       |     | String  | Registry URL; use `https://harbor.local/` |
| `run_config`            |     | Object  | Runtime params (e.g., `hostname`, `privileged`) |
| `exec_config`           |     | Object  | Extra execution params |
| `notes`                 |     | String  | Operational notes and requirements |
| `cores`                 |     | Integer | CPU cores reserved |
| `memory`                |     | Integer | Memory (MB) reserved |
| `gpu_count`             |     | Integer | GPUs reserved |
| `cpu_allocation_method` |     | String  | `Inherit`, `Quotas`, or `Shares` |

**Compatibility object**:

```
{
  "version": "1.16.x",
  "image": "harbor.local/<name>:<tag>",
  "uncompressed_size_mb": 0,
  "available_tags": ["develop", "<semver>", "<rolling-tags>"]
}
```

### 5.3 Authoring standards

- **Registry**: Use `docker_registry` set to `https://harbor.local/`.  
- **Images**: Every `compatibility[*].image` value **must** start with `harbor.local/`.  
- **Hostname**: When specifying `run_config.hostname`, use `skylusws`.  
- **Text**: Keep descriptions short and product‑focused.  
- **Icons**: Prefer square `.png` or `.svg`, 50×50px or larger.

### 5.4 Minimal example

```json
{
  "friendly_name": "Visual Studio Code",
  "image_src": "vs-code.png",
  "description": "Code editor for modern development.",
  "cores": 2,
  "memory": 2768,
  "gpu_count": 0,
  "cpu_allocation_method": "Inherit",
  "docker_registry": "https://harbor.local/",
  "categories": ["Development"],
  "require_gpu": false,
  "enabled": true,
  "image_type": "Container",
  "architecture": ["amd64", "arm64"],
  "compatibility": [
    {
      "version": "1.16.x",
      "image": "harbor.local/vs-code:1.16.0-rolling-daily",
      "uncompressed_size_mb": 2428,
      "available_tags": ["develop", "1.16.0", "1.16.0-rolling-weekly", "1.16.0-rolling-daily"]
    }
  ]
}
```

### 5.5 Example with runtime and notes

```json
{
  "friendly_name": "Google Chrome",
  "image_src": "chrome.png",
  "description": "Google Chrome browser for secure web access.",
  "cores": 2,
  "memory": 2768,
  "gpu_count": 0,
  "cpu_allocation_method": "Inherit",
  "docker_registry": "https://harbor.local/",
  "categories": ["Browser"],
  "require_gpu": false,
  "enabled": true,
  "image_type": "Container",
  "run_config": {
    "hostname": "skylusws"
  },
  "exec_config": {
    "go": {
      "cmd": "bash -c '/dockerstartup/custom_startup.sh --go --url \"$SKYLUS_URL\"'"
    },
    "assign": {
      "cmd": "bash -c '/dockerstartup/custom_startup.sh --assign --url \"$SKYLUS_URL\"''"
    }
  },
  "notes": "This workspace may require additional seccomp configuration depending on the host distribution.",
  "architecture": ["amd64"],
  "compatibility": [
    {
      "version": "1.16.x",
      "image": "harbor.local/chrome:1.16.1-rolling-daily",
      "uncompressed_size_mb": 3096,
      "available_tags": ["develop", "1.16.0", "1.16.0-rolling-weekly", "1.16.0-rolling-daily"]
    },
    {
      "version": "1.17.0",
      "image": "harbor.local/chrome:1.17.0-rolling-daily",
      "uncompressed_size_mb": 2934,
      "available_tags": ["develop", "1.17.0", "1.17.0-rolling-weekly", "1.17.0-rolling-daily"]
    }
  ]
}
```

---

## 6) Versioning & channels

- Add a `compatibility` entry for each Skylus Workspaces version you support.  
- Use `available_tags` to expose release channels (for example, `develop`, semantic tags, rolling tags).  
- Keep tags consistent across the catalog for a clear storefront experience.

---

## 7) Publishing & consumption

- Commit workspace changes to the default schema branch (for example `1.1`).  
- After the build completes, use the **Workspace Registry Link** from the storefront in the Skylus Workspaces Admin to add/update this registry.  
- Users can then browse, filter, and install workspaces from the Skylus interface.

---

## 8) Maintenance guidelines

- Periodically review `uncompressed_size_mb` to keep size estimates accurate.  
- Retire deprecated tags and add new images when upstream releases occur.  
- Prefer consistent naming and icon quality across the catalog.

---

## 9) Operational notes

- Some workspaces may require specific seccomp or AppArmor profiles; document these in `notes`.  
- GPU‑enabled images must set `gpu_count` appropriately and should clearly state requirements in the description/notes.  
- Use `run_config.privileged` sparingly and only when strictly necessary.

---

## 10) FAQ

**How are updates reflected?**  
Commits to this repository trigger the build and update process. The storefront and backend stay aligned automatically.

**Which registry should I use for images?**  
Set `docker_registry` to `https://harbor.local/` and prefix all `compatibility[*].image` values with `harbor.local/`.

**What hostname should I set?**  
Use `run_config.hostname` with the value `skylusws` when a hostname is required.

**Can I include external images or links in this README?**  
Keep this document focused and lightweight. Only the official Skylus logo is embedded here.

---

## 11) Ownership

**Skylus Harbor Registry** and **Skylus Workspaces** are products of **Netweb Technologies India Ltd.**  
© Netweb Technologies India Ltd. All rights reserved.
