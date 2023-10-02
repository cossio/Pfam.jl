import Pfam
using Test: @test

Pfam.set_pfam_directory(mktempdir())
Pfam.set_pfam_version("35.0")

pdbmap = Pfam.pdbmap()
@test isfile(pdbmap)

stk_file = Pfam.alignment_file("PF00013")
@test isfile(stk_file)
