# oceanlib (Power Query + DAX edition)

[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE) [![Power BI](https://img.shields.io/badge/Power%20BI-yellow?logo=powerbi&logoColor=white)](#) [![Power Query M / DAX UDF](https://img.shields.io/badge/Power%20Query%20M%20%2F%20DAX%20UDF-blue)](#)

A small physical-oceanography toolkit built entirely in M (Power
Query) and DAX -- no Python required anywhere in this version.

## What's here

**`power-query/`** -- one `.m` file per custom function. Each is
meant to be pasted into a Blank Query's Advanced Editor in Power BI
Desktop, then invoked as a custom column or standalone step.

| File                                                    | Does                                                              |
| ------------------------------------------------------- | ----------------------------------------------------------------- |
| `fn_SoundSpeedMackenzie.m`                              | Speed of sound in seawater (Mackenzie 1981 formula)               |
| `fn_ApproxDensity.m`                                    | Simplified seawater density estimate                              |
| `fn_PracticalSalinity.m`                                | Practical salinity from conductivity ratio (PSS-78, UNESCO 1981)  |
| `fn_ClassifyWaterMass.m`                                | Water mass ID from a T-S pair (range lookup vs. published envelopes) |
| `fn_SubInertialFilter.m`                                | Moving-average low-pass filter (approximates sub-inertial signal) |
| `fn_QCFlag.m`                                           | Range-based QC flag (1 = pass, 4 = fail)                          |
| `fn_KnotsToMs.m`, `fn_MsToKnots.m`, `fn_DbarToMetres.m` | Unit conversions                                                  |
| `fn_HaversineDistance.m`                                | Great-circle distance between two lat/lon points                  |
| `fn_InitialBearing.m`                                   | Initial bearing (forward azimuth) between two lat/lon points      |
| `fn_DestinationPoint.m`                                 | Destination lat/lon given a start point, bearing, and distance    |

**`dax/oceanlib_udfs.dax`** -- DAX user-defined functions (Power BI
Desktop/Service, June 2026 GA onward): `TidalForecast`, `ApproxDensity`,
`SoundSpeedMackenzie`, `PracticalSalinity`, `ClassifyWaterMass`,
`HaversineDistance`, `InitialBearing`, `DestinationLat`, `DestinationLon`.
Also includes `Atan2`, an internal helper (DAX has no native ATAN2) that
the bearing/distance/destination functions call internally -- not
meant to be called directly, but documented since it's a model-level
function like the others. These are model-level functions you can
call from any measure.

> **Note:** `ApproxDensity` currently has two definitions with
> different signatures floating around in draft versions of this file
> -- a two-parameter `(TemperatureC, SalinityPSU)` version with no
> depth term, and the three-parameter `(Salinity, TemperatureC, Depth)`
> version documented below. Only one should exist in the final file;
> keep the three-parameter version (it accounts for depth, and matches
> the caveat section below) and remove or rename the other before
> loading this into a model.

## Tides: what has to happen before you can forecast

`TidalForecast` reconstructs a tide from known harmonic constituents
(a frequency, amplitude, and phase for each of M2, S2, K1, O1, etc.)
-- it does **not** derive those constituents from raw data. Fitting
them is a least-squares solve, which doesn't translate well into M or
DAX (no linear algebra engine), so that step is deliberately left out
of this scaffold.

Before `TidalForecast` is usable, you need a small `Constituents` table (columns: `Frequency_cph`, `Amplitude`, `Phase_deg`) loaded into
the model. Two ways to get it, neither requiring Python:

1. **Published constituents for a real station** -- NOAA CO-OPS (US
stations, freely available) or UKHO/Admiralty tide tables (UK
stations) publish amplitude/phase per constituent. Pull these once
and load as a static table.
2. **A one-off external fit** -- if you still have old MATLAB
`T_TIDE`/UTide output from university, or get someone to run the
fit once outside Power BI, load just the resulting table.

Either way, everything downstream (the DAX UDF, any measure that uses
it) only ever touches that small table -- never the raw time series.

## Sub-inertial filtering caveat

`fn_SubInertialFilter.m` uses a centred moving average rather than a
proper digital (e.g. Butterworth) filter, since M has no signal-
processing library. Set the window to roughly one inertial period at
your latitude. It's a reasonable approximation, not a research-grade
filter -- there will be some edge effects and less clean frequency
separation than a proper filter design would give.

## Density caveat

`fn_ApproxDensity.m` / `ApproxDensity` (DAX) use a simplified,
linearised formula -- not the full TEOS-10 equation of state, which is
a large polynomial fit that isn't practical to hand-code in M or DAX.
The DAX version linearises around a reference point (T0 = 10°C,
S0 = 35 PSU, Rho0 = 1025 kg/m3) using representative thermal
expansion / haline contraction coefficients, plus a small linear
correction for the pressure increase with depth. It's an own
linearisation, not a derivation of a published standard.

This is fine for a rough estimate or a quick in-model lookup, but
don't rely on it where accuracy matters (e.g. anything feeding a
scientific calculation downstream). Valid roughly for T: 0-30°C,
S: 30-40 PSU -- accuracy degrades near freezing and in fresh/brackish
water, and it does not capture cabbeling or thermobaric effects
(mixing two water masses of different T/S can produce water denser
than either parent -- a linear equation of state can't represent
this). If you need TEOS-10-accurate density, the practical route is
to compute it once elsewhere (e.g. the TEOS-10 GSW toolbox, or an
online calculator) and load the results as a table, the same pattern
as the tidal constituents above.

## Sound speed caveat

`fn_SoundSpeedMackenzie.m` / `SoundSpeedMackenzie` (DAX) use the
Mackenzie (1981) empirical equation, valid roughly for temperature
-2 to 30°C, salinity 30-40 PSU, and depth 0-8000 m. Outside that
range the formula isn't guaranteed accurate. It's a widely used,
publicly documented equation, not a derived/fitted result, so there's
no equivalent "external fit" step needed here -- it just has a
validity range to keep in mind.

## Practical salinity caveat

`fn_PracticalSalinity.m` / `PracticalSalinity` (DAX) implement PSS-78
(UNESCO 1981) at atmospheric pressure only -- no pressure correction
term is applied, so this assumes a surface or near-surface
conductivity reading. A published, standard formula, not derived
in-house.

## Water mass classification caveat

`fn_ClassifyWaterMass.m` / `ClassifyWaterMass` (DAX) identify a water
mass from a T-S pair using a range lookup against published T-S
envelopes -- the simple alternative to a full optimum multiparameter
(OMP) mixing analysis, which solves for fractional contributions of
several source water masses and requires a linear solve not practical
in M or DAX.

Five of the seven categories are sourced from published literature:

| Water mass | T range | S range | Source |
| --- | --- | --- | --- |
| Antarctic Bottom Water (AABW) | -0.8 to 2°C | 34.6-35.0 | Wikipedia, citing Schmidt et al. |
| North Atlantic Deep Water (NADW) | 2.2-3.5°C | 34.90-34.97 | Britannica |
| Antarctic Intermediate Water (AAIW) | 3-7°C | 33.8-34.5 | Britannica |
| Mediterranean Water (MW) | 10.5-14°C | 36.5-37.5 | Fusco et al., Gulf of Cadiz study |
| North Atlantic Central Water (NACW) | 5.0-18.0°C | 34.3-35.8 | Emery & Meincke 1986, via Ifremer review |

The remaining two categories ("Subtropical Surface Water" and
"Subpolar Surface Water") are **generic, uncited buckets** -- broad
catch-alls for evaporation-dominated vs. precipitation/melt-dominated
surface water, not sourced from a specific reference, and clearly
less authoritative than the five ranges above.

**Read before using:** even the sourced ranges are open-ocean,
large-scale reference values -- not a regional climatology for any
specific study area. Water mass T-S signatures vary geographically
and with mixing, so for real work, verify these ranges against
literature for your actual region rather than relying on this
general-purpose version.

## QC flag

`fn_QCFlag.m` checks a single numeric measurement -- e.g. a
temperature, salinity, elevation, or current speed reading -- against
a valid range you supply, and returns a flag: `1` (pass) if the value
falls within `ValidMin`/`ValidMax`, `4` (fail) if it's outside that
range or blank/null. The valid range is up to you to set per
variable (e.g. temperature might be 0-35°C, salinity 0-40 PSU) --
the function itself has no built-in sense of what's "normal" for any
particular measurement.

**Caveat:** it only does this range check -- it does not detect
spikes (a value that jumps abnormally compared to its neighbours),
since that needs access to adjacent rows, not just a single cell.
If you also want spike detection, that would need to run as a
separate step over the whole column (e.g. comparing each row to the
one before/after it in a Power Query table transform) rather than as
a simple per-value function like this one.

## Unit conversions

`fn_KnotsToMs.m`, `fn_MsToKnots.m`, and `fn_DbarToMetres.m` are exact
conversions (or, for dbar-to-metres, the standard oceanographic
approximation that 1 dbar ≈ 1 m) -- no caveats beyond what's noted in
each file's comments.

## Distance between coordinates

`fn_HaversineDistance.m` / `HaversineDistance` (DAX) calculate the
great-circle distance between two lat/lon points, in metres, using
the Haversine formula. This is a well-established pattern in the
Power BI community -- people commonly need it for things like finding
the nearest location to a given point -- but it's normally hand-built
as a one-off measure, since neither DAX nor M has a built-in distance
function.

**Caveats:**

- **Spherical approximation.** Haversine treats the Earth as a
perfect sphere, which is accurate to within about 0.5%. That's fine
for most survey/navigation/reporting purposes, but if you need
geodetic precision (e.g. surveying-grade accuracy), you'd want
Vincenty's formula on an ellipsoid instead -- an iterative
calculation that's considerably less clean to hand-code in M or DAX.
- **Radians conversion.** A common mistake (seen repeatedly in
community troubleshooting threads) is forgetting to convert
degrees to radians before the trig calls, or converting
inconsistently between the two points -- this tends to produce
results that are either wildly wrong or suspiciously identical
for every row. Both functions here handle the conversion
internally (`Number.ToRadians` in M, `RADIANS()` in DAX), so you
only need to pass in plain decimal-degree coordinates.

## Bearing and destination-point caveats

`fn_InitialBearing.m` / `InitialBearing` (DAX) and
`fn_DestinationPoint.m` / `DestinationLat`/`DestinationLon` (DAX) use
the same spherical-Earth assumption as `HaversineDistance` -- accurate
to about 0.5%, fine for reporting/navigation use, not geodetic-grade.
DAX splits destination point into two separate scalar functions
(`DestinationLat`, `DestinationLon`) since a UDF can only return one
value; call both with the same inputs to get a full coordinate pair.

## Licensing

Everything here is original formulas or hand-written M/DAX -- no
third-party code included, so there's nothing to attribute or license
beyond your own choice for this repo.
