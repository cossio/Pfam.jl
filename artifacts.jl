#= Code to populate Artifacts.toml. This file is only used in development. =#

using Pkg.Artifacts, SHA

"""
    artifact_pfamdb_file(name)

Adds a database file from Pfam to the Artifacts.toml of this package.
This file is only used in development.
"""
function artifact_pfamdb_file(name::String)
    toml = joinpath(@__DIR__, "Artifacts.toml")
    sha = "";
    filename = "$name.txt.gz"
    url = "ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam33.0/database_files/$filename"
    artifact_hash = create_artifact() do artifact_dir
        out = joinpath(artifact_dir, filename)
        run(`wget $url -O $out`)
        sha = bytes2hex(sha256(joinpath(artifact_dir, name)))
    end
    bind_artifact!(toml, name, artifact_hash; lazy=true, download_info=[(url, sha)])
end

artifact_pfamdb_file("uniprot")
artifact_pfamdb_file("pfamseq")



#=
    md5 checksums of database files
=#
toml = joinpath(@__DIR__, "Artifacts.toml")
sha = "";
url = "ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam32.0/database_files/md5_checksums"
artifact = create_artifact() do artifact_dir
    out = joinpath(artifact_dir, "md5_checksums")
    download("ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam32.0/database_files/md5_checksums", out)
    sha = bytes2hex(sha256(out))
end
bind_artifact!(toml, "pfamdbmd5", artifact; lazy=false, download_info=[(url, sha)])
