# Pfam Julia package

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://cossio.github.io/Pfam.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://cossio.github.io/Pfam.jl/dev)
![](https://github.com/cossio/Pfam.jl/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/cossio/Pfam.jl/branch/master/graph/badge.svg?token=HL6RUVR384)](https://codecov.io/gh/cossio/Pfam.jl)

Julia package to interact with the Pfam database.

```julia
using Pfam
msa = Pfam.MSA("PF00011")  # describe the requested MSA
df = Pfam.load(msa) # load as a DataFrame
```
