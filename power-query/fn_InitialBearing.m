// fn_InitialBearing
// Initial bearing (forward azimuth), in degrees from true north (0-360),
// from point 1 to point 2. Uses the standard spherical bearing formula --
// the same trig family as fn_HaversineDistance.m, answering "which
// direction" rather than "how far."
//
// Usage: fn_InitialBearing([Lat1], [Lon1], [Lat2], [Lon2])

(Lat1 as number, Lon1 as number, Lat2 as number, Lon2 as number) as number =>
let
    Phi1 = Number.ToRadians(Lat1),
    Phi2 = Number.ToRadians(Lat2),
    DeltaLambda = Number.ToRadians(Lon2 - Lon1),

    Y = Number.Sin(DeltaLambda) * Number.Cos(Phi2),
    X = Number.Cos(Phi1) * Number.Sin(Phi2)
        - Number.Sin(Phi1) * Number.Cos(Phi2) * Number.Cos(DeltaLambda),

    ThetaRad = Number.Atan2(Y, X),
    ThetaDeg = ThetaRad * 180 / Number.PI,
    Bearing = (ThetaDeg + 360) - 360 * Number.RoundDown((ThetaDeg + 360) / 360)
in
    Bearing
