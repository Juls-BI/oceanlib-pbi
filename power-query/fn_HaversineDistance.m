// fn_HaversineDistance
// Great-circle distance between two lat/lon points (metres), using
// the Haversine formula. Not a built-in M function -- there isn't one
// -- this is built from the underlying trig functions (Number.Sin,
// Number.Cos, Number.Atan2), which is the standard way this gets done
// in Power Query.
//
// Usage: fn_HaversineDistance([Lat1], [Lon1], [Lat2], [Lon2])

(Lat1 as number, Lon1 as number, Lat2 as number, Lon2 as number) as number =>
let
    R = 6371000,
    Phi1 = Number.ToRadians(Lat1),
    Phi2 = Number.ToRadians(Lat2),
    DeltaPhi = Number.ToRadians(Lat2 - Lat1),
    DeltaLambda = Number.ToRadians(Lon2 - Lon1),
    A = Number.Sin(DeltaPhi / 2) * Number.Sin(DeltaPhi / 2)
        + Number.Cos(Phi1) * Number.Cos(Phi2) * Number.Sin(DeltaLambda / 2) * Number.Sin(DeltaLambda / 2),
    C = 2 * Number.Atan2(Number.Sqrt(1 - A), Number.Sqrt(A)),
    Distance = R * C
in
    Distance
