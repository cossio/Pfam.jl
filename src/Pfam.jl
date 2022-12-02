module Pfam

using Downloads: download
using Preferences: @set_preferences!, @load_preference
import Gzip_jll
using MD5: md5
using DelimitedFiles: readdlm

# make the loading PFAM files thread-safe
const PFAM_LOCK = ReentrantLock()

# Stores downloaded Rfam files
const PFAM_DIR = @load_preference("PFAM_DIR")
const PFAM_VERSION = @load_preference("PFAM_VERSION")

if isnothing(PFAM_DIR)
    @warn """PFAM_DIR not set; use `set_pfam_directory` and restart Julia.
    Otherwise you will need to pass a `dir` option to every function.
    """
end

if isnothing(PFAM_VERSION)
    @warn """PFAM_VERSION not set; use `set_pfam_version` and restart Julia.
    Otherwise you will need to pass a `version` option to every function.
    """
end

function set_pfam_directory(dir::AbstractString)
    @set_preferences!("PFAM_DIR" => dir)
    @info "PFAM Directory $dir set; restart Julia for this change to take effect."
end

function set_pfam_version(version)
    @set_preferences!("PFAM_VERSION" => version)
    @info "Pfam version $version set; restart Julia for this change to take effect."
end

base_url(; version=PFAM_VERSION) = "https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam$version"
version_dir(; dir=PFAM_DIR, version=PFAM_VERSION) = mkpath(joinpath(dir, version))

pdbmap(; dir::AbstractString=PFAM_DIR, version::AbstractString=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(; dir, version), "pdbmap")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        pfam_base_url = base_url(; version)
        download("$pfam_base_url/pdbmap.gz", "$local_path.gz"; timeout = Inf)
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_hmm_dat(; dir::AbstractString=PFAM_DIR, version::AbstractString=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(; dir, version), "Pfam-A.hmm.dat")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        pfam_base_url = base_url(; version)
        download("$pfam_base_url/Pfam-A.hmm.dat.gz", "$local_path.gz"; timeout = Inf)
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_hmm(; dir::AbstractString=PFAM_DIR, version::AbstractString=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(; dir, version), "Pfam-A.hmm")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        pfam_base_url = base_url(; version)
        download("$pfam_base_url/Pfam-A.hmm.gz", "$local_path.gz"; timeout = Inf)
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_seed(; dir::AbstractString=PFAM_DIR, version::AbstractString=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(; dir, version), "Pfam-A.seed")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        pfam_base_url = base_url(; version)
        download("$pfam_base_url/Pfam-A.seed.gz", "$local_path.gz"; timeout = Inf)
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_full(; dir::AbstractString=PFAM_DIR, version::AbstractString=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(; dir, version), "Pfam-A.full")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        pfam_base_url = base_url(; version)
        download("$pfam_base_url/Pfam-A.full.gz", "$local_path.gz"; timeout = Inf)
        gunzip("$local_path.gz")
    end
    return local_path
end

pfamseq(; dir::AbstractString=PFAM_DIR, version::AbstractString=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(; dir, version), "pfamseq")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        pfam_base_url = base_url(; version)
        download("$pfam_base_url/pfamseq.gz", "$local_path.gz"; timeout = Inf)
        gunzip("$local_path.gz")
    end
    return local_path
end

uniprot(; dir::AbstractString=PFAM_DIR, version::AbstractString=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(; dir, version), "uniprot")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        pfam_base_url = base_url(; version)
        download("$pfam_base_url/uniprot.gz", "$local_path.gz"; timeout = Inf)
        gunzip("$local_path.gz")
    end
    return local_path
end

# decompress a gunzipped file
gunzip(file::AbstractString) = run(`$(Gzip_jll.gzip()) -d $file`)

end # module
