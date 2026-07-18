// fn_DestinationPoint
// Given a start point, initial bearing, and distance, calculates the
// destination point (the reverse of fn_HaversineDistance.m /
// fn_InitialBearing.m). Returns a record with Latitude and Longitude
// fields.
//
// Usage: fn_DestinationPoint([Lat1], [Lon1], [Bearing], [Distance])
// then expand the resulting record's Latitude/Longitude fields into
// columns.

(Lat1 as number, Lon1 as number, BearingDeg as number, DistanceM as number) as record =>
let
    R = 6371000,
    Delta = DistanceM / R,
    Theta = Number.ToRadians(BearingDeg),
    Phi1 = Number.ToRadians(Lat1),
    Lambda1 = Number.ToRadians(Lon1),
    Phi2 = Number.Asin(
        Number.Sin(Phi1) * Number.Cos(Delta)
        + Number.Cos(Phi1) * Number.Sin(Delta) * Number.Cos(Theta)
    ),
    Lambda2 = Lambda1 + Number.Atan2(
        Number.Sin(Theta) * Number.Sin(Delta) * Number.Cos(Phi1),
        Number.Cos(Delta) - Number.Sin(Phi1) * Number.Sin(Phi2)
    ),
    Result = [
        Latitude = Number.ToDegrees(Phi2),
        Longitude = Number.ToDegrees(Lambda2)
    ]
in
    Result
