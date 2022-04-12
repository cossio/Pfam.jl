"""
    MSA

Describes parameters of an MSA.
"""
Base.@kwdef struct MSA
    id::String					# Pfam id (required)
    aln::String = "full"		# -Full
    format::String = "fasta"	# -Format:FASTA
    order::String = "t"			# -Order:Tree
    case::String = "l"			# -Sequence:Inserts lower case
    gaps::String = "default"	# -Gaps:Gaps as "." or "-"(mixed)

    function MSA(
        id::String, aln::String, format::String, order::String, case::String, gaps::String
    )
        if is_valid_pfam_id(id)
            return new(id, aln, format, order, case, gaps)
        else
            error("$id is not a valid Pfam code")
        end
    end
end

MSA(id::String; kwargs...) = MSA(; id=id, kwargs...)

function is_valid_pfam_id(id::String)
    return occursin(r"^PF\d{5}$"i, id)
end

function url(msa::MSA)
    return (
        "https://pfam.xfam.org/family/$(msa.id)/alignment/full/format?" *
        "format=$(msa.format)&" *
        "alnType=$(msa.aln)&" *
        "order=$(msa.order)&" *
        "case=$(msa.case)&" *
        "gaps=$(msa.gaps)&" *
        "download=1"
    )
end

function file(msa::MSA)
    return (
        "pfam_$(msa.id)_" *
        "format=$(msa.format)_" *
        "alnType=$(msa.aln)_" *
        "order=$(msa.order)_" *
        "case=$(msa.case)_" *
        "gaps=$(msa.gaps)"
    )
end

path(msa::MSA) = joinpath(pfam_msa_scratch, file(msa))

function download(msa::MSA)
    @info "Downloading $(msa.id)"
    #= PFAM has expired certificates. So we need this or `download` will fail.
    TODO: check if the certificates at PFAM got fixed =#
    withenv("JULIA_NO_VERIFY_HOSTS" => "pfam.xfam.org", ENV...) do
        Downloads.download(url(msa), path(msa); timeout = Inf)
    end
end

"""
    load(msa)

Loads an MSA.
"""
function load(msa::MSA)
    if !isfile(path(msa))
        download(msa)
    end

    df = DataFrame(uniprot_id = String[], start = Int[], stop = Int[], sequence = String[])
    FastaReader(path(msa)) do fr
        for (desc, seq) in fr
            id, start, stop = split(desc, ['>', '/', '-']; keepempty=false)
            push!(df, (id, parse(Int, start), parse(Int, stop), seq))
        end
    end

    return df
end

"""
    remove_inserts(sequence)

Remove inserts from a string sequence.
"""
function remove_inserts(sequence::String)
    return filter(c -> c == '-' || c ≠ lowercase(c), sequence)
end
