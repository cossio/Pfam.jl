using Test: @test
import Pfam

dir = mktempdir()
version = "35.0"

Pfam_hmm = Pfam.Pfam_A_hmm(; dir, version)
@test isfile(Pfam_hmm)
