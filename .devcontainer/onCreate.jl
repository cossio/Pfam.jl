import Pkg

Pkg.Registry.add(Pkg.RegistrySpec(url="https://github.com/cossio/CossioJuliaRegistry.git"))
Pkg.Registry.add("General")

# add some packages to global env
Pkg.activate()
Pkg.add([
    "CairoMakie",
    "Makie",
    "MyRegistrator",
    "ProgressMeter",
    "PythonPlot",
    "Revise",
    "StatsBase",
    "Unitful",
    "ViennaRNA_jll",
    "ViennaRNA",
])

# instantiate project
Pkg.activate(pwd())
Pkg.update()
