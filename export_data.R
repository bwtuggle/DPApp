# Re-creates everything in data/ from the dashboard's original DPAppData.RData.
# Run this whenever the RData is updated, then re-upload the site folder.
# Needs: sf, jsonlite, plotly, viridisLite.   Usage: Rscript export_data.R path/to/DPAppData.RData
suppressMessages({library(sf); library(jsonlite); library(plotly)})
args <- commandArgs(trailingOnly = TRUE)
e <- new.env(); load(if (length(args)) args[1] else "DPAppData.RData", e)
dir.create("data", showWarnings = FALSE)

# 1. Each pre-built plotly chart -> plain JSON (name minus the "plotly" suffix)
for (n in grep("plotly$", ls(e), value = TRUE))
  writeLines(as.character(plotly_json(e[[n]], jsonedit = FALSE)),
             file.path("data", paste0(sub("plotly$", "", n), ".json")))

# 2. Tract map: one feature per tract, with e_<group> / moe_<group> columns
x <- st_transform(e$bvue_tracts_map, 4326); d <- st_drop_geometry(x)
g <- x[!duplicated(x$GEOID), c("GEOID", "NAME")]
for (v in unique(d$variable)) {
  s <- d[d$variable == v, ]
  g[[paste0("e_", v)]]   <- s$e[match(g$GEOID, s$GEOID)]
  g[[paste0("moe_", v)]] <- s$moe[match(g$GEOID, s$GEOID)]
}
unlink("data/tracts.geojson")
st_write(g, "data/tracts.geojson", quiet = TRUE, layer_options = "COORDINATE_PRECISION=5")

# 3. Quick-facts table and the (reversed) inferno palette used by the map
write_json(e$facts, "data/facts.json", pretty = TRUE)
write(toJSON(rev(viridisLite::inferno(256))), "data/inferno.json")
