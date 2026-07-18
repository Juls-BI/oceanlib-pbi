![License](https://img.shields.io/badge/license-MIT-green)
![Power BI](https://img.shields.io/badge/Power%20BI-yellow?logo=powerbi&logoColor=white)
![Power Query M / DAX UDF](https://img.shields.io/badge/Power%20Query%20M%20%2F%20DAX%20UDF-blue)

# oceanlib (Power Query + DAX edition)

A small physical-oceanography toolkit built entirely in M (Power
Query) and DAX -- no Python required anywhere in this version.

## What's here

**`power-query/`** -- one `.m` file per custom function. Each is
meant to be pasted into a Blank Query's Advanced Editor in Power BI
Desktop, then invoked as a custom column or standalone step.

| File | Does |
|---|---|
| `fn_SoundSpeedMackenzie.m` | Speed of sound in seawater (Mackenzie 1981 formula) |
| `fn_ApproxDensity.m` | Simplified seawater density estimate |
| `fn_SubInertialFilter.m` | Moving-average low-pass filter (approximates sub-inertial signal) |
| `fn_QCFlag.m` | Range-based QC flag (1 = pass, 4 = fail) |
| `fn_KnotsToMs.m`, `fn_MsToKnots.m`, `fn_DbarToMetres.m` | Unit conversions |

**`dax/oceanlib_udfs.dax`** -- DAX user-defined functions (Power BI
Desktop/Service, June 2026 GA onward): `TidalForecast`, `ApproxDensity`,
`SoundSpeedMackenzie`. These are model-level functions you can call
from any measure.

## Tides: what has to happen before you can forecast

`TidalForecast` reconstructs a tide from known harmonic constituents
(a frequency, amplitude, and phase for each of M2, S2, K1, O1, etc.)
-- it does **not** derive those constituents from raw data. Fitting
them is a least-squares solve, which doesn't translate well into M or
DAX (no linear algebra engine), so that step is deliberately left out
of this scaffold.

Before `TidalForecast` is usable, you need a small `Constituents`
table (columns: `Frequency_cph`, `Amplitude`, `Phase_deg`) loaded into
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
This is fine for a rough estimate or a quick in-model lookup, but
don't rely on it where accuracy matters (e.g. anything feeding a
scientific calculation downstream). If you need TEOS-10-accurate
density, the practical route is to compute it once elsewhere (e.g.
the TEOS-10 GSW toolbox, or an online calculator) and load the
results as a table, the same pattern as the tidal constituents above.

## Sound speed caveat

`fn_SoundSpeedMackenzie.m` / `SoundSpeedMackenzie` (DAX) use the
Mackenzie (1981) empirical equation, valid roughly for temperature
-2 to 30°C, salinity 30-40 PSU, and depth 0-8000 m. Outside that
range the formula isn't guaranteed accurate. It's a widely used,
publicly documented equation, not a derived/fitted result, so there's
no equivalent "external fit" step needed here -- it just has a
validity range to keep in mind.

## QC flag caveat

`fn_QCFlag.m` only does a range test (is the value within valid
min/max) -- it does not do spike/neighbour-based detection, since
that needs access to adjacent rows, not just a single cell. If you
want spike detection too, it would need to run as a step over the
whole column (e.g. comparing each row to the previous/next in a
Power Query table transform) rather than as a simple per-value
function like this one.

## Unit conversions

`fn_KnotsToMs.m`, `fn_MsToKnots.m`, and `fn_DbarToMetres.m` are exact
conversions (or, for dbar-to-metres, the standard oceanographic
approximation that 1 dbar ≈ 1 m) -- no caveats beyond what's noted in
each file's comments.

## Licensing

Everything here is original formulas or hand-written M/DAX -- no
third-party code included, so there's nothing to attribute or license
beyond your own choice for this repo.
