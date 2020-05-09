using LocalStore, DataDeps
using Pkg.Artifacts

struct Taxonomy
	msa::MSA
end

Base.hash(tax::Taxonomy, h::UInt) = hash("Pfam.Taxonomy", hash(tax.msa, h))
file(tax::Taxonomy) = "pfam_$(tax.msa.id)_taxonomy.txt"

function LocalStore.save(obj::Taxonomy, dir::String)
	df = LocalStore.load(obj.msa)
	msa_ids = Dict(id => k for (k, id) in enumerate(df.uniprot_id))
	msa_tax = Array{Union{Missing,String}}(missing, size(df, 1))
	msa_tax .= missing
	open(datadep"uniprot/uniprot.txt.gz") do io
		gzip = GzipDecompressorStream(io)
		for line in eachline(gzip)
			rows = split(line, "\t")
			id = rows[2]
			if haskey(msa_ids, id)
				@assert length(rows) == 22
				msa_tax[msa_ids[id]] = rows[10]
			end
		end
	end
	dftax = DataFrame(uniprot_id = df.uniprot_id, taxonomy = msa_tax)
	CSV.write(joinpath(dir, file(obj)), dftax)
end

function LocalStore.load(obj::Taxonomy, dir::String)
	CSV.read(joinpath(dir, file(obj)))
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
