# Pfam.jl

`Pfam.jl` downloads and caches files from [Pfam](https://www.ebi.ac.uk/interpro/entry/pfam/).

## Installation

```julia
using Pkg
Pkg.add("Pfam")
```

## Setup

Before downloading files, configure a local cache directory and the Pfam release to use:

```julia
import Pfam

Pfam.set_pfam_directory(mkpath(joinpath(homedir(), ".pfam")))
Pfam.set_pfam_version("35.0")
```

The chosen values are stored with `Preferences.jl`, so they persist across Julia sessions.

## Usage

Each helper downloads a file the first time it is requested and then returns the local cached path.

```julia
import Pfam

pdbmap_path = Pfam.pdbmap()
hmm_path = Pfam.Pfam_A_hmm()
seed_alignment_path = Pfam.alignment_file("PF00013", :seed)
```

## Available download helpers

- `Pfam.pdbmap()`
- `Pfam.Pfam_A_hmm_dat()`
- `Pfam.Pfam_A_hmm()`
- `Pfam.Pfam_A_seed()`
- `Pfam.Pfam_A_full()`
- `Pfam.Pfam_A_fasta()`
- `Pfam.pfamseq()`
- `Pfam.uniprot()`
- `Pfam.alignment_file(id, which=:full)`

`Pfam.alignment_file` downloads Stockholm alignments for a Pfam family identifier such as `PF00013`. The `which` argument accepts `:full`, `:seed`, and `:uniprot`.
