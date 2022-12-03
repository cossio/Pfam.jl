module Pfam

using Downloads: download
using Preferences: @set_preferences!, @load_preference
import Gzip_jll
using ProgressMeter: ProgressUnknown, update!

# make loading Pfam files thread-safe
const PFAM_LOCK = ReentrantLock()

# Stores downloaded Pfam files
const PFAM_DIR = @load_preference("PFAM_DIR")
const PFAM_VERSION = @load_preference("PFAM_VERSION")

function set_pfam_directory(dir)
    @set_preferences!("PFAM_DIR" => dir)
    @info "PFAM directory $dir set; restart Julia for this change to take effect."
end

function set_pfam_version(version)
    @set_preferences!("PFAM_VERSION" => version)
    @info "Pfam version $version set; restart Julia for this change to take effect."
end

base_url() = base_url(PFAM_VERSION)
version_dir() = version_dir(PFAM_DIR, PFAM_VERSION)
alignment_files_dir() = alignment_files_dir(PFAM_DIR)

base_url(version::AbstractString) = "https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam$version"
version_dir(dir::AbstractString, version::AbstractString) = mkpath(joinpath(dir, version))
alignment_files_dir(dir::AbstractString) = mkpath(joinpath(dir, "alignment_files"))

base_url(::Any) = config_error()
version_dir(::Any, ::Any) = config_error()
alignment_files_dir(::Any) = config_error()

config_error() = throw(ArgumentError(
    """
    PFAM version and/or directory not set; use `set_pfam_version` / `set_pfam_directory`
    and restart Julia. Otherwise you might need to pass `version` and/or `dir` options
    to most functions.
    """
))

pdbmap(; dir=PFAM_DIR, version=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(dir, version), "pdbmap")
    if !isfile(local_path)
        @info "Downloading to $local_path ..."
        download_progress("$(base_url(version))/pdbmap.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_hmm_dat(; dir=PFAM_DIR, version=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(dir, version), "Pfam-A.hmm.dat")
    if !isfile(local_path)
        @info "Downloading to $local_path ..."
        download_progress("$(base_url(version))/Pfam-A.hmm.dat.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_hmm(; dir=PFAM_DIR, version=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(dir, version), "Pfam-A.hmm")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        download_progress("$(base_url(version))/Pfam-A.hmm.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_seed(; dir=PFAM_DIR, version=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(dir, version), "Pfam-A.seed")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        download_progress("$(base_url(version))/Pfam-A.seed.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_full(; dir=PFAM_DIR, version=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(dir, version), "Pfam-A.full")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        download_progress("$(base_url(version))/Pfam-A.full.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_fasta(; dir=PFAM_DIR, version=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(dir, version), "Pfam-A.fasta")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        download_progress("$(base_url(version))/Pfam-A.fasta.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

pfamseq(; dir=PFAM_DIR, version=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(dir, version), "pfamseq")
    if !isfile(local_path)
        @info "Downloading pfamseq to $local_path ..."
        download_progress("$(base_url(version))/pfamseq.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

uniprot(; dir=PFAM_DIR, version=PFAM_VERSION) = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(dir, version), "uniprot")
    if !isfile(local_path)
        @info "Downloading to $local_path ..."
        download_progress("$(base_url(version))/uniprot.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

"""
    alignment_file(id, which=:full, dir=PFAM_DIR)

Download an alignment file in Pfam Stockholm format. `which` can be one of: `:full` (default), `:seed`, or `:uniprot`.
"""
alignment_file(id, which=:full; dir=PFAM_DIR) = lock(PFAM_LOCK) do
    local_path = joinpath(alignment_files_dir(dir), "$id.alignment.$which.stk")
    if !isfile(local_path)
        @info "Downloading to $local_path ..."
        url = "https://www.ebi.ac.uk/interpro/wwwapi//entry/pfam/$id/?annotation=alignment:$which&download"
        download_progress(url, "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

# decompress a gunzipped file
gunzip(file) = run(`$(Gzip_jll.gzip()) -d $file`)

function download_progress(url, path; timeout=Inf)
    progress_bar = ProgressUnknown("Downloaded (bytes):")
    download(url, path; timeout, progress=(total, now) -> update!(progress_bar, now))
end

end # module
