// fn_SoundSpeedMackenzie
// Speed of sound in seawater (m/s), Mackenzie (1981) empirical equation.
// Valid roughly for T: -2 to 30 C, S: 30 to 40 PSU, depth: 0 to 8000 m.
//
// Usage: create a Blank Query, paste this into the Advanced Editor,
// name the query fn_SoundSpeedMackenzie, then invoke it as a custom
// column: fn_SoundSpeedMackenzie([Salinity], [Temperature], [Depth])

(Salinity as number, TemperatureC as number, Depth as number) as number =>
let
    T = TemperatureC,
    S = Salinity,
    D = Depth,
    Speed =
        1448.96
        + 4.591 * T
        - 5.304e-2 * Number.Power(T, 2)
        + 2.374e-4 * Number.Power(T, 3)
        + 1.340 * (S - 35)
        + 1.630e-2 * D
        + 1.675e-7 * Number.Power(D, 2)
        - 1.025e-2 * T * (S - 35)
        - 7.139e-13 * T * Number.Power(D, 3)
in
    Speed
