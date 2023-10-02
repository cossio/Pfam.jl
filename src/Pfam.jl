module Pfam

import Gzip_jll
using Downloads: download
using Preferences: @set_preferences!, @load_preference
using ProgressMeter: ProgressUnknown, update!

# make loading Pfam files thread-safe
const PFAM_LOCK = ReentrantLock()

include("preferences.jl")

function base_url()
    version = get_pfam_version()
    return "https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam$version"
end

function version_dir()
    pfam_dir = get_pfam_directory()
    version = get_pfam_version()
    return mkpath(joinpath(pfam_dir, version))
end

function alignment_files_dir()
    pfam_dir = get_pfam_directory()
    return mkpath(joinpath(pfam_dir, "alignment_files"))
end

pdbmap() = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(), "pdbmap")
    if !isfile(local_path)
        @info "Downloading to $local_path ..."
        download_progress("$(base_url())/pdbmap.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_hmm_dat() = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(), "Pfam-A.hmm.dat")
    if !isfile(local_path)
        @info "Downloading to $local_path ..."
        download_progress("$(base_url())/Pfam-A.hmm.dat.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_hmm() = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(), "Pfam-A.hmm")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        download_progress("$(base_url())/Pfam-A.hmm.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_seed() = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(), "Pfam-A.seed")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        download_progress("$(base_url())/Pfam-A.seed.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_full() = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(), "Pfam-A.full")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        download_progress("$(base_url())/Pfam-A.full.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

Pfam_A_fasta() = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(), "Pfam-A.fasta")
    if !isfile(local_path)
        @info "Downloading pdbmap to $local_path ..."
        download_progress("$(base_url())/Pfam-A.fasta.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

pfamseq() = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(), "pfamseq")
    if !isfile(local_path)
        @info "Downloading pfamseq to $local_path ..."
        download_progress("$(base_url())/pfamseq.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

uniprot() = lock(PFAM_LOCK) do
    local_path = joinpath(version_dir(), "uniprot")
    if !isfile(local_path)
        @info "Downloading to $local_path ..."
        download_progress("$(base_url())/uniprot.gz", "$local_path.gz")
        gunzip("$local_path.gz")
    end
    return local_path
end

"""
    alignment_file(id, which=:full)

Download an alignment file in Pfam Stockholm format. `which` can be one of: `:full` (default), `:seed`, or `:uniprot`.
"""
alignment_file(id, which=:full) = lock(PFAM_LOCK) do
    local_path = joinpath(alignment_files_dir(), "$id.alignment.$which.stk")
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
    progress_bar = ProgressUnknown(; desc = "Downloaded (bytes):")
    download(url, path; timeout, progress=(total, now) -> update!(progress_bar, now))
end

end # module
