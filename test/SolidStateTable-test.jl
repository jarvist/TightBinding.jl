# Test the solid state table. Mostly data entry / lookups work.

println(SST[AtoZ["B"]])

@test SST[AtoZ["Be"]].kF == 1.94
@test SST[AtoZ["As"]].ϵp == 7.91
@test SST[AtoZ["I"]].ϵs == 19.42

