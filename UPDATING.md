# How to update this dashboard

You only ever edit three kinds of things: **data files** (`data/`), **text/settings in `index.html`**,
and (rarely) the **basemap**. You can edit `index.html` in any text editor (Notepad, VS Code, RStudio).
No build step: save the file, refresh the browser.

## 0. Preview your changes locally
In R (from the folder that contains `index.html`):

    httpuv::runStaticServer(".")      # then open the address it prints

(Opening index.html by double-clicking does NOT work, because browsers block loading the data files.)
Press Ctrl+Shift+R in the browser to force a refresh after each edit.

## 1. Refresh the data (most common update)
1. Rebuild your charts/map in R as you do today and save `DPAppData.RData`.
2. In this folder run: `Rscript export_data.R path/to/DPAppData.RData`
3. Check the preview, then re-upload the `data/` folder to the host.
`index.html` does not need to change for a data refresh, unless the *text* mentions years or
table names (see 2).

## 2. Edit text, titles and sources
Everything readable lives in two places in `index.html`:

| What | Where to look (use Ctrl+F) |
|---|---|
| Page title / tagline at the top | `<h1>` and the `<p>` just under it, near the top of `<body>` |
| Left sidebar text | the `<aside>` block |
| Tab names, chart titles, "Source:" lines | the `TABS = [` list in the script. One `{ ... }` entry per tab, in display order |
| Map dropdown choices | the `GROUPS = [` list |
| Map starting position/zoom | `MAP_CENTER` and `MAP_ZOOM` near the top of the script |

Example: to change a year in a title, find the tab in `TABS` and edit its `title:` text.
Keep the quotes and the comma at the end of each line. A source link is written with the helper
`a("https://link", "link text")`, joined to other text with `+`.

## 3. Add, remove or reorder a tab
- **Reorder/remove:** move or delete the whole `{ id: ..., ... },` entry in `TABS`.
- **Add a chart tab:**
  1. In R, make the plotly object and name it ending in `plotly`, e.g. `incomeplotly`, and save it in the RData.
  2. Run `export_data.R` — it writes `data/income.json` automatically.
  3. Copy an existing `type: "plot"` entry in `TABS`, then change `id` (unique, no spaces), `label`
     (the tab text), `data` (`"income"` — the file name without `.json`), `title`, and `src`.
- Tab types are `"plot"` (a chart), `"map"` (the tract map) and `"facts"` (the Quick Facts table).

## 4. Add a group to the map dropdown
Make sure the new group's name appears in the `variable` column of `bvue_tracts_map`, re-run
`export_data.R`, then add one line to `GROUPS`: `["Label shown to users", "VariableName"],`.

## 5. Colors, fonts and layout
Colors/fonts are in the `<style>` block at the top. `--brand` is the blue used for the title.
Chart colors come from the R plots themselves, so change those in R and re-export.
Chart height is `.chart { height: 400px; }` (the map uses `#map`).

## 6. The basemap (background map)
Settings are in the `BASEMAP = { ... }` block at the top of the script. The page tries the
OpenFreeMap "Positron" style first. If that cannot load (blocked by a network filter, no WebGL,
or the service is down) it automatically falls back to greyed OpenStreetMap tiles, and shows a small
note if neither works. The tract layer always displays.
**If the basemap is missing:** open the page, press F12, click "Console", and look for a line starting
"Vector basemap unavailable (...)" — the text in brackets is the reason. If your organization's firewall
or Content-Security-Policy restricts outside sites, ask IT to allow `tiles.openfreemap.org` and
`tile.openstreetmap.org`. To use another provider, change `vectorStyle` (any MapLibre style URL) or `rasterUrl`
(any `{z}/{x}/{y}` tile URL) and update its attribution text, which must stay visible.

## 7. Publishing
Upload the whole folder (keep the structure: `index.html`, `data/`, `lib/`). On GitHub, commit and push;
the included workflow publishes it to GitHub Pages.

## 8. If something breaks
Press F12 > Console in the browser. A red message names the file or line at fault. The most common
causes are a missing quote or comma in the `TABS` list, or a `data:` name that doesn't match a file in `data/`.
Keep a copy of the last working `index.html` before editing.
