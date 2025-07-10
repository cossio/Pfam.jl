module Pfam

import Gzip_jll
using Downloads: download
using Preferences: @load_preference, @set_preferences!
using ProgressMeter: ProgressUnknown, update!

# make loading Pfam files thread-safe
const PFAM_LOCK = ReentrantLock()

include("preferences.jl")

function base_url(; pfam_version = get_pfam_version())
    return "https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam$pfam_version"
end

function version_dir(; pfam_dir = get_pfam_directory(), pfam_version = get_pfam_version())
    return mkpath(joinpath(pfam_dir, pfam_version))
end

function alignment_files_dir(; pfam_dir = get_pfam_directory())
    return mkpath(joinpath(pfam_dir, "alignment_files"))
end

function pdbmap(; pfam_dir = get_pfam_directory(), pfam_version = get_pfam_version())
    local_path = joinpath(version_dir(; pfam_dir, pfam_version), "pdbmap")
    lock(PFAM_LOCK) do
        if !isfile(local_path)
            @info "Downloading to $local_path ..."
            download_progress("$(base_url(; pfam_version))/pdbmap.gz", "$local_path.gz")
            gunzip("$local_path.gz")
        end
    end
    return local_path
end

function Pfam_A_hmm_dat(; pfam_dir = get_pfam_directory(), pfam_version = get_pfam_version())
    local_path = joinpath(version_dir(; pfam_dir, pfam_version), "Pfam-A.hmm.dat")
    lock(PFAM_LOCK) do
        if !isfile(local_path)
            @info "Downloading to $local_path ..."
            download_progress("$(base_url(; pfam_version))/Pfam-A.hmm.dat.gz", "$local_path.gz")
            gunzip("$local_path.gz")
        end
    end
    return local_path
end

function Pfam_A_hmm(; pfam_dir = get_pfam_directory(), pfam_version = get_pfam_version())
    local_path = joinpath(version_dir(; pfam_dir, pfam_version), "Pfam-A.hmm")
    lock(PFAM_LOCK) do
        if !isfile(local_path)
            @info "Downloading pdbmap to $local_path ..."
            download_progress("$(base_url(; pfam_version))/Pfam-A.hmm.gz", "$local_path.gz")
            gunzip("$local_path.gz")
        end
    end
    return local_path
end

function Pfam_A_seed(; pfam_dir = get_pfam_directory(), pfam_version = get_pfam_version())
    local_path = joinpath(version_dir(; pfam_dir, pfam_version), "Pfam-A.seed")
    lock(PFAM_LOCK) do
        if !isfile(local_path)
            @info "Downloading pdbmap to $local_path ..."
            download_progress("$(base_url(; pfam_version))/Pfam-A.seed.gz", "$local_path.gz")
            gunzip("$local_path.gz")
        end
    end
    return local_path
end

function Pfam_A_full(; pfam_dir = get_pfam_directory(), pfam_version = get_pfam_version())
    local_path = joinpath(version_dir(; pfam_dir, pfam_version), "Pfam-A.full")
    lock(PFAM_LOCK) do
        if !isfile(local_path)
            @info "Downloading pdbmap to $local_path ..."
            download_progress("$(base_url(; pfam_version))/Pfam-A.full.gz", "$local_path.gz")
            gunzip("$local_path.gz")
        end
    end
    return local_path
end

function Pfam_A_fasta(; pfam_dir = get_pfam_directory(), pfam_version = get_pfam_version())
    local_path = joinpath(version_dir(; pfam_dir, pfam_version), "Pfam-A.fasta")
    lock(PFAM_LOCK) do
        if !isfile(local_path)
            @info "Downloading pdbmap to $local_path ..."
            download_progress("$(base_url(; pfam_version))/Pfam-A.fasta.gz", "$local_path.gz")
            gunzip("$local_path.gz")
        end
    end
    return local_path
end

function pfamseq(; pfam_dir = get_pfam_directory(), pfam_version = get_pfam_version())
    local_path = joinpath(version_dir(; pfam_dir, pfam_version), "pfamseq")
    lock(PFAM_LOCK) do
        if !isfile(local_path)
            @info "Downloading pfamseq to $local_path ..."
            download_progress("$(base_url(; pfam_version))/pfamseq.gz", "$local_path.gz")
            gunzip("$local_path.gz")
        end
    end
    return local_path
end

function uniprot(; pfam_dir = get_pfam_directory(), pfam_version = get_pfam_version())
    local_path = joinpath(version_dir(; pfam_dir, pfam_version), "uniprot")
    lock(PFAM_LOCK) do
        if !isfile(local_path)
            @info "Downloading to $local_path ..."
            download_progress("$(base_url(; pfam_version))/uniprot.gz", "$local_path.gz")
            gunzip("$local_path.gz")
        end
    end
    return local_path
end

"""
    alignment_file(id, which=:full)

Download an alignment file in Pfam Stockholm format. `which` can be one of: `:full` (default), `:seed`, or `:uniprot`.
"""
function alignment_file(id, which=:full; pfam_dir = get_pfam_directory())
    local_path = joinpath(alignment_files_dir(; pfam_dir), "$id.alignment.$which.stk")
    lock(PFAM_LOCK) do
        if !isfile(local_path)
            @info "Downloading to $local_path ..."
            url = "https://www.ebi.ac.uk/interpro/wwwapi/entry/pfam/$id/?annotation=alignment:$which&download"
            download_progress(url, "$local_path.gz")
            gunzip("$local_path.gz")
        end
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
