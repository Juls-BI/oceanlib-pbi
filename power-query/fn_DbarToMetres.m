// fn_DbarToMetres
// Rough conversion from sea pressure (dbar) to depth (m).
// 1 dbar ~= 1 m in the ocean; this is a standard rough approximation,
// not a full pressure-to-depth integration accounting for local
// gravity/density.
//
// Usage: fn_DbarToMetres([Pressure])

(PressureDbar as number) as number =>
    PressureDbar * 1.019716
