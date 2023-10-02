# Pfam Julia package

Julia package to download files from [Pfam](https://www.ebi.ac.uk/interpro/entry/pfam/).

```julia
import Pfam
file_path = Pfam.pdbmap() # returns path to pdbmap file containing mapping between PFAM families and PDB structures
```