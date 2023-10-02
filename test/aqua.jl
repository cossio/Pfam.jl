import Aqua
import Pfam
using Test: @testset

@testset verbose = true "aqua" begin
    Aqua.test_all(Pfam)
end
