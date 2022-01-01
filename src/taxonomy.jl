taxonomy_path(msa::MSA) = path(msa) * "_taxonomy"

function load_with_taxonomy(msa::MSA)
    if !isfile(taxonomy_path(msa))
        df = load(msa)
        tax = get_taxonomies(df.uniprot_id)
        dftax = DataFrame(uniprot_id = df.uniprot_id, taxonomy = tax)
        CSV.write(taxonomy_path(msa), dftax)
    end
    return CSV.read(taxonomy_path(msa), DataFrame)
end

function get_taxonomies(uniprot_ids::AbstractVector{String})
    idx = Dict(id => k for (k, id) in enumerate(uniprot_ids))
    tax = Vector{Union{Missing,String}}(undef, length(uniprot_ids))
    tax .= missing
    open(datadep"uniprot/uniprot.txt.gz") do io
        gzip = GzipDecompressorStream(io)
        for line in eachline(gzip)
            rows = split(line, "\t")
            id = rows[2]
            if haskey(idx, id)
                @assert length(rows) == 22
                tax[idx[id]] = rows[10]
            end
        end
    end
    return tax
end

#
# function uniprot_headers()
# 	headers = [
# 		(:uniprot_acc, String), (:uniprot_id, String),
# 		(:seq_version, Int), (:crc64, String), (:md5, String),
# 		(:description, String), (:evidence, Int), (:length, Int),
# 		(:species, String), (:taxonomy, String),
# 		(:is_fragment, Int), (:sequence, String),
# 		(:updated, String),	(:created, String),
# 		(:ncbi_taxid, Int),	(:ref_proteome, Int),
# 		(:complete_proteome, Int), (:treefam_acc, String),
# 		(:rp15, Int), (:rp35, Int), (:rp55, Int), (:rp75, Int)
# 	]
# end
#
# function uniprot_taxonomy_table()
# 	uniprot_headers = uniprot_csv_headers()
# 	uniprot_csv() do csv
# 		df = csv |> select(:uniprot_id, :taxonomy) |> DataFrame
# 	end
# 	return df
# end
#
# function uniprot_csv(f)
# 	io = open(datadep"uniprot/uniprot.txt.gz")
# 	try
# 		gzip = GzipDecompressorStream(io)
# 		csv = CSV.File(gzip; header=first.(headers), types=last.(headers))
# 		f(csv)
# 	finally
# 		close(io)
# 	end
# end
