// fn_PracticalSalinity
// Practical salinity from conductivity ratio, PSS-78 (UNESCO 1981) --
// a published, standard formula, not derived here. Assumes atmospheric
// pressure (no pressure correction term applied -- see caveat in the
// README).
//
// Usage: fn_PracticalSalinity([ConductivityRatio], [Temperature])
// where ConductivityRatio (Rt) is the conductivity ratio relative to
// standard seawater at the same temperature.

(ConductivityRatio as number, TemperatureC as number) as number =>
let
    R = ConductivityRatio,
    T = TemperatureC,
    K = 0.0162,
    BaseTerm =
        0.0080
        - 0.1692 * Number.Power(R, 0.5)
        + 25.3851 * R
        + 14.0941 * Number.Power(R, 1.5)
        - 7.0261 * Number.Power(R, 2)
        + 2.7081 * Number.Power(R, 2.5),
    TempCorrection =
        (T - 15) / (1 + K * (T - 15))
        * (
            0.0005
            - 0.0056 * Number.Power(R, 0.5)
            - 0.0066 * R
            - 0.0375 * Number.Power(R, 1.5)
            + 0.0636 * Number.Power(R, 2)
            - 0.0144 * Number.Power(R, 2.5)
        ),
    Salinity = BaseTerm + TempCorrection
in
    Salinity
