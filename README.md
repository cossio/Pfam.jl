# Pfam Julia package

![](https://github.com/cossio/Pfam.jl/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/cossio/Pfam.jl/branch/master/graph/badge.svg?token=HL6RUVR384)](https://codecov.io/gh/cossio/Pfam.jl)

Julia package to download files from [Pfam](https://www.ebi.ac.uk/interpro/entry/pfam/).

```julia
import Pfam
file_path = Pfam.pdbmap() # returns path to pdbmap file containing mapping between PFAM families and PDB structures
```