// fn_QCFlag
// QARTOD-style QC flag for a single value: 1 = pass, 4 = fail.
// (Suspect/spike testing is left out here since it needs neighbouring
// values, not just one cell -- better done as a separate step over
// the whole column if needed.)
//
// Usage: fn_QCFlag([Value], 0, 40)

(Value as nullable number, ValidMin as number, ValidMax as number) as number =>
    if Value = null or Value < ValidMin or Value > ValidMax then 4 else 1
