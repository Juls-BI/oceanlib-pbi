// fn_ApproxDensity
// Simplified, linearised seawater density estimate (kg/m^3).
// NOT a substitute for the full TEOS-10 equation of state -- use this
// only where a rough estimate is good enough. For accurate density,
// you'd need the full TEOS-10 formulation, which is not practical to
// hand-code in M (it's a large polynomial fit); consider sourcing
// pre-computed density values instead if accuracy matters.
//
// Usage: paste into a Blank Query's Advanced Editor, name it
// fn_ApproxDensity, invoke as: fn_ApproxDensity([Temperature], [Salinity])

(TemperatureC as number, SalinityPSU as number) as number =>
let
    Density =
        1000
        + 0.78 * SalinityPSU
        - 0.20 * TemperatureC
        - 0.0055 * Number.Power(TemperatureC, 2)
in
    Density
