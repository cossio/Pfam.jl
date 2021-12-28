#=
Load the PF00011 family from PFAM.
=#

using Pfam
msa = Pfam.MSA("PF00011")  ## describe the requested MSA
df = Pfam.load(msa) ## load as a DataFrame
