using DataFrames, FastaIO, CSV, CodecZlib

Base.@kwdef struct MSASpec
	pfamcode::String			# Pfam id
	aln::String = "full"		# -Full
	format::String = "fasta"	# -Format:FASTA
	order::String = "t"			# -Order:Tree
	case::String = "l"			# -Sequence:Inserts lower case
	gaps::String = "default"	# -Gaps:Gaps as "." or "-"(mixed)
	function MSASpec(pfamcode::String; aln::String = "full",
					 format::String = "fasta", order::String = "order",
					 case::String = "l", gaps::String = "default")
		occursin(r"^PF\d{5}$"i, pfamcode) || throw(ErrorException("$pfamcode is not a correct Pfam code"))
		new(pfamcode, aln, format, order, case, gaps)
	end
end

function url(msa::MSASpec)
	"https://pfam.xfam.org/family/$(msa.pfamcode)/alignment/full/format?" *
		"format=$(msa.format)&" *
		"alnType=$(msa.aln)&" *
		"order=$(msa.order)&" *
		"case=$(msa.case)&" *
		"gaps=$(msa.gaps)&" *
		"download=1"
end

function localpath(msa::MSASpec)
	joinpath(pfam_dir(), "msa", bytes2hex(sha256(url(msa))))
end

function Base.read(msa::MSASpec)
	df = DataFrame(uniprot_id = String[], start = Int[], stop = Int[], sequence = String[])
	FastaReader(download_file(msa)) do fr
           for (desc, seq) in fr
			   id, start, stop = split(desc, ['>', '/', '-']; keepempty=false)
			   push!(df, (id, parse(Int, start), parse(Int, stop), seq))
           end
       end
	return df
end

function remove_inserts!(msa::DataFrame)
	msa.sequence = remove_inserts.(msa.sequence)
end

function remove_inserts(sequence::String)
	filter(c -> c == '-' || c ≠ lowercase(c), sequence)
end

function taxonomy(msa::DataFrame, level::Int)
	tax = uniprot_taxonomy_table()
	tax.taxonomy = [split(s, "; ")[level] for s in tax.taxonomy]
	join(msa, tax, on = :uniprot_id)
end

function uniprot_taxonomy_table()
	uniprot_headers = uniprot_csv_headers()
	uniprot_csv() do csv
		df = csv |> select(:uniprot_id, :taxonomy) |> DataFrame
	end
	return df
end

function uniprot_csv(f)
	headers = [
		(:uniprot_acc, String), (:uniprot_id, String),
		(:seq_version, Int), (:crc64, String), (:md5, String),
		(:description, String), (:evidence, Int), (:length, Int),
		(:species, String), (:taxonomy, String),
		(:is_fragment, Int), (:sequence, String),
		(:updated, String),	(:created, String),
		(:ncbi_taxid, Int),	(:ref_proteome, Int),
		(:complete_proteome, Int), (:treefam_acc, String),
		(:rp15, Int), (:rp35, Int), (:rp55, Int), (:rp75, Int)
	]
	io = open(datadep"uniprot/uniprot.txt.gz")
	try
		gzip = GzipDecompressorStream(io)
		csv = CSV.File(gzip; header=first.(headers), types=last.(headers))
		f(csv)
	finally
		close(io)
	end
end


#
# function remove_inserts(msa::DataFrame)
#
# 	open(path(msa) * "_noinserts", "w") do file
# 		for (i, line) in enumerate(eachline(path(msa)))
# 			if first(line) == '>'
# 				println(file, i > 1 ? '\n' * line : line)
# 			else
# 				for c in strip(line)
# 					if c == '-' || c ≠ lowercase(c)
# 						print(file, c)
# 					end
# 				end
# 			end
# 		end
# 	end
# end

#get_pfam("PF00091")
