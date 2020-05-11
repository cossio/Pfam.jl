# Pfam

Julia package to interact with the Pfam database.

```julia
using Pfam
msa = Pfam.MSA("PF00011")  # describe the requested MSA
df = Pfam.load(msa) # load as a DataFrame
```
