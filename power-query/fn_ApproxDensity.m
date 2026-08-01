// fn_ApproxDensity
// Approximate seawater density via linearisation around a reference
// point (T0 = 10 degC, S0 = 35 PSU, Rho0 = 1025 kg/m3), using
// representative thermal expansion / haline contraction coefficients,
// plus a small linear correction for pressure increase with depth.
// NOT the full TEOS-10 equation of state -- a large polynomial fit
// impractical to hand-code in M. Own linearisation around a
// reference point, not a derivation of a published standard.
//
// Valid roughly for T: 0 to 30 degC, S: 30 to 40 PSU -- accuracy
// degrades near freezing and in fresh/brackish water. Does not
// capture cabbeling or thermobaric effects (mixing two water masses
// of different T/S can produce water denser than either parent -- a
// linear equation of state can't represent this).
//
// Good for a rough estimate or in-model comparison; don't rely on it
// for anything feeding a scientific calculation downstream -- if you
// need TEOS-10-accurate density, compute it once elsewhere (e.g. the
// TEOS-10 GSW toolbox or an online calculator) and load the results
// as a table instead.
//
// Usage: paste into a Blank Query's Advanced Editor, name it
// fn_ApproxDensity, invoke as:
// fn_ApproxDensity([Salinity], [Temperature], [Depth])
(Salinity as number, TemperatureC as number, Depth as number) as number =>
let
    T = TemperatureC,
    S = Salinity,
    D = Depth,
    Rho0 = 1025,
    T0 = 10,
    S0 = 35,
    Alpha = 0.0002,   // per degC
    Beta = 0.00076,   // per PSU
    Kappa = 0.0045,   // kg/m3 per metre
    Density =
        Rho0
        * (1 - Alpha * (T - T0) + Beta * (S - S0))
        + Kappa * D
in
    Density
