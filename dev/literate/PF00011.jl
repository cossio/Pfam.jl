#=
Load the PF00011 family from PFAM.
=#

import Pfam
msa = Pfam.MSA("PF00011");  ## describe the requested MSA
df = Pfam.load(msa); ## load as a DataFrame
@show df[1:50,:]; ## show some rows
