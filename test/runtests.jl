using Test: @test
import Pfam

dir = mktempdir()
version = "35.0"

pdbmap = Pfam.pdbmap(; dir, version)
@test isfile(pdbmap)

stk_file = Pfam.alignment_file("PF00013"; dir)
@test isfile(stk_file)
