// fn_ClassifyWaterMass
// Simplified water mass identification from a temperature/salinity
// pair, using a T-S diagram-style range lookup. This is the "simple"
// approach to water mass ID -- checking which published T-S envelope
// a point falls into -- as opposed to a full optimum multiparameter
// (OMP) mixing analysis, which solves for fractional contributions
// of several source water masses and requires a linear solve not
// practical in M or DAX.
//
// SOURCES for the five named water masses below (see README for full
// citations):
//   AABW  -- T -0.8 to 2C,  S 34.6-35.0   (Wikipedia, citing Schmidt et al.)
//   NADW  -- T 2.2-3.5C,    S 34.90-34.97 (Britannica)
//   AAIW  -- T 3-7C,        S 33.8-34.5   (Britannica)
//   MW    -- T 10.5-14C,    S 36.5-37.5   (Fusco et al., Gulf of Cadiz study)
//   NACW  -- T 5.0-18.0C,   S 34.3-35.8   (Emery & Meincke 1986, via Ifremer review)
//
// The two "Surface Water" categories are NOT from a specific citation
// -- they're generic descriptive buckets (subtropical/evaporative vs.
// subpolar/fresher surface water), included only as a broad catch-all
// and clearly less authoritative than the five sourced ranges above.
//
// IMPORTANT -- read before using:
// Even the sourced ranges are open-ocean, large-scale reference
// values, not a regional climatology for your specific study area.
// Water mass T-S signatures vary geographically and with mixing, so
// for real work you should verify these against literature for your
// actual region rather than relying on this general-purpose version.
//
// Usage: fn_ClassifyWaterMass([Temperature], [Salinity])

(TemperatureC as number, SalinityPSU as number) as text =>
let
    T = TemperatureC,
    S = SalinityPSU,
    Result =
        if T >= -0.8 and T <= 2 and S >= 34.6 and S <= 35.0 then
            "Antarctic Bottom Water (AABW)"
        else if T > 2 and T <= 3.5 and S >= 34.90 and S <= 34.97 then
            "North Atlantic Deep Water (NADW)"
        else if T > 3 and T <= 7 and S >= 33.8 and S <= 34.5 then
            "Antarctic Intermediate Water (AAIW)"
        else if T >= 10.5 and T <= 14 and S >= 36.5 and S <= 37.5 then
            "Mediterranean Water (MW) -- Gulf of Cadiz values"
        else if T >= 5.0 and T <= 18.0 and S >= 34.3 and S <= 35.8 then
            "North Atlantic Central Water (NACW)"
        else if T >= 20 and S >= 36 then
            "Subtropical Surface Water (generic, uncited) -- evaporation-dominated"
        else if T < 10 and S < 34.3 then
            "Subpolar Surface Water (generic, uncited) -- precipitation/melt-dominated"
        else
            "Unclassified / mixed -- outside defined reference ranges"
in
    Result
