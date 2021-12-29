import Pfam

msa = Pfam.MSA("PF00011")
df = Pfam.load(msa)

@test size(df, 1) > 10000
@test size(df, 2) == 4
@test "H0TRS9_9BRAD" ∈ df.uniprot_id
