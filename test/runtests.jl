using Test: @test
import Pfam

dir = mktempdir()
version = "35.0"

pdbmap = Pfam.pdbmap(; dir, version)
@test isfile(pdbmap)
