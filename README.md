# Benefit-Harm

Interactive app exploring how adolescents conceptualize helping and aggressing behaviors
(benefit-harm, extent of impact, and collective dyadic power), with gender- and
power-specific multidimensional scaling results.

**Live app:** https://shanemccarty.github.io/benefit-harm/

Accompanies: McCarty, S.M., & Dunsmore, J.C. (2023). Adolescents' perceptions of helping and
aggressing at school: Salience of benefit-harm, extent of impact, and collective dyadic power.
*Current Psychology, 42*(31), 27153-27166. https://doi.org/10.1007/s12144-022-03806-4

## Versions
- **v1:** Created Spring 2021 by Shane McCarty and Bryan Acton (RStudio 1.3.1056, Shiny 1.6.0).
- **v2:** Updated with Claude Sonnet 5.5 in Fall 2026; now runs entirely in the browser with
  [Shinylive](https://posit-dev.github.io/r-shinylive/) (no server needed).

## Files
- `app/` - the Shiny app (`app.R`) and its data (`Coordinates.csv`, `Vignettes.csv`)
- `docs/` - the exported Shinylive site served by GitHub Pages
- `export.R` - rebuilds `docs/` after changing the app

## Update the app
1. Edit `app/app.R`.
2. Run `Rscript export.R`.
3. Commit and push; GitHub Pages updates automatically.

Preview locally: `Rscript -e 'httpuv::runStaticServer("docs")'` (open in Chrome or Safari).
