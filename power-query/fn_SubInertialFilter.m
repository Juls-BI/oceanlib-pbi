// fn_SubInertialFilter
// Approximate sub-inertial (low-pass) filter using a centred moving
// average, applied to a list of evenly-sampled values.
//
// This is a simple, dependency-free stand-in for a proper Butterworth
// filter -- good enough to separate the slow (subtidal / wind- and
// pressure-driven) signal from the faster tidal-band signal, but less
// clean than a real digital filter (some leakage at the edges of the
// window, no explicit frequency-domain cutoff).
//
// Choose HalfWindowSamples so that the full window (2*HalfWindowSamples+1)
// spans roughly one inertial period at your latitude. E.g. at 45N the
// inertial period is about 17 hours; with hourly data, HalfWindowSamples
// = 8 gives a ~17-hour window.
//
// Usage: paste into a Blank Query's Advanced Editor, name it
// fn_SubInertialFilter. Invoke on a column turned into a list:
//   fn_SubInertialFilter(Table.Column(#"PreviousStep", "Elevation"), 8)
// then expand the result back into the table (row order must match).
// To get the supra-inertial component, subtract this result from the
// original column in a second custom column.

(Values as list, HalfWindowSamples as number) as list =>
let
    Count = List.Count(Values),
    Indices = List.Numbers(0, Count),
    Smoothed = List.Transform(
        Indices,
        each
            let
                i = _,
                lo = List.Max({0, i - HalfWindowSamples}),
                hi = List.Min({Count - 1, i + HalfWindowSamples}),
                window = List.Range(Values, lo, hi - lo + 1)
            in
                List.Average(window)
    )
in
    Smoothed
