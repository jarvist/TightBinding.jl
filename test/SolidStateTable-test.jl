# Test the solid state table. Mostly data entry / lookups work.

println(SST[ZfromAtom["B"]])

@test SST[ZfromAtom["Be"]].kF == 1.94

