module PfamTaxonomies

function pfam_load_without_taxonomy(id::String)
    path = pfam_fasta(id)
    df = DataFrame(uniprot_id = String[], start = Int[], stop = Int[], sequence = String[])
    FastaIO.FastaReader(path) do fr
        for (desc, seq) in fr
            id, start, stop = split(desc, ['>', '/', '-']; keepempty=false)
            push!(df, (id, parse(Int, start), parse(Int, stop), seq))
        end
    end
    @assert sort(reduce(union, collect.(df.sequence))) ⊆ collect("-.ABCDEFGHIKLMNPQRSTVWXYacdefghiklmnpqrstvwxy")
    return df
end

function pfam_load_with_taxonomy(id::String)
    df = pfam_load_without_taxonomy(id)
    tax = CSV.read(pfam_taxonomy(id), DataFrame)
    df.taxonomy = tax.taxonomy
    return df
end

function pfam_taxonomy(id::String)
    path = joinpath(pfam_taxonomy_dir(), "$id.txt")
    lock(PFAM_LOCK) do
        if !isfile(path)
            @info "Constructing taxonomy file for $id ..."
            df = pfam_load_without_taxonomy(id)
            tax = fetch_taxonomies(df.uniprot_id)
            dftax = DataFrame(uniprot_id = df.uniprot_id, taxonomy = tax)
            CSV.write(path, dftax)
            @info "Taxonomy file saved for $id"
        end
    end
    return path
end

function find_taxonomies(uniprot_ids::AbstractVector{String})
    idx = Dict(id => k for (k, id) in enumerate(uniprot_ids))
    tax = Vector{Union{Missing,String}}(missing, length(uniprot_ids))
    for line in eachline(Pfam.uniprot())
        rows = split(line, "\t")
        id = rows[2]
        if haskey(idx, id)
            @assert length(rows) == 22
            tax[idx[id]] = rows[10]
        end
    end
    return tax
end

end # module
