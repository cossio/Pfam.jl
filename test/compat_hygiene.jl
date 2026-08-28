import Pfam
import TestCompatHygiene
using Test: @testset

@testset verbose = true "compat hygiene" begin
    TestCompatHygiene.test_all(Pfam)
end
