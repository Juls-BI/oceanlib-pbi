// fn_ClassifyWaterMass
// Simplified water mass identification from a temperature/salinity
// pair, using a T-S diagram-style range lookup. This is the "simple"
// approach to water mass ID -- checking which published T-S envelope
// a point falls into -- as opposed to a full optimum multiparameter
// (OMP) mixing analysis, which solves for fractional contributions
// of several source water masses and requires a linear solve not
// practical in M or DAX.
//
// SOURCES for the six named water masses below (see README for full
// citations):
//   AABW  -- T -0.8 to 2C,  S 34.6-35.0    (Wikipedia, citing Schmidt et al.)
//   NADW  -- T 2.2-3.5C,    S 34.90-34.97  (Britannica)
//   NPIW  -- T 4.5-8.0C,    S 33.7-34.0    (salinity-minimum core values; see README)
//   AAIW  -- T 3-7C,        S 33.8-34.5    (Britannica)
//   MW    -- T 10.5-14C,    S 36.5-37.5    (Fusco et al., Gulf of Cadiz study)
//   NACW  -- T 5.0-18.0C,   S 34.3-35.8    (Emery & Meincke 1986, via Ifremer review)
//
// NPIW is checked before AAIW: their ranges partially overlap, and
// NPIW's narrower salinity-minimum signature is the more specific /
// diagnostic match, so it gets first refusal in a first-match-wins
// SWITCH/if-chain -- same principle as sourced ranges taking priority
// over the generic buckets further down.
//
// The two "Surface Water" categories are NOT from a specific citation
// -- they're generic descriptive buckets (subtropical/evaporative vs.
// subpolar/fresher surface water), included only as a broad catch-all
// and clearly less authoritative than the six sourced ranges above.
//
// KNOWN GAP: no North Pacific Deep Water (NPDW) category yet -- no
// citable modern T-S range was found for it during research; see
// README caveat. Deep North Pacific water may currently fall into
// AABW, AAIW, or Unclassified depending on where it happens to land
// numerically, none of which is a confirmed correct match for NPDW.
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
        else if T >= 4.5 and T <= 8.0 and S >= 33.7 and S <= 34.0 then
            "North Pacific Intermediate Water (NPIW)"
        else if T > 3 and T <= 7 and S >= 33.8 and S <= 34.5 then
            "Antarctic Intermediate Water (AAIW)"
        else if T >= 10.5 and T <= 14 and S >= 36.5 and S <= 37.5 then
            "Mediterranean Water (MW)"
        else if T >= 5.0 and T <= 18.0 and S >= 34.3 and S <= 35.8 then
            "North Atlantic Central Water (NACW)"
        else if T >= 20 and S >= 36 then
            "Subtropical Surface Water (generic)"
        else if T < 10 and S < 34.3 then
            "Subpolar Surface Water (generic)"
        else
            "Unclassified / mixed"
in
    Result
