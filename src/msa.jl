using DataFrames, FastaIO, CSV, CodecZlib, LocalStore, GZip, Downloads

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
        if !is_valid_pfam_id(id)
            error("$id is not a valid Pfam code")
        end
        return new(id, aln, format, order, case, gaps)
    end
end

MSA(id::String; kwargs...) = MSA(; id=id, kwargs...)

function is_valid_pfam_id(id::String)
    return occursin(r"^PF\d{5}$"i, id)
end

# need to define for LocalStore
function Base.hash(msa::MSA, h::UInt)
	h = hash("Pfam.MSA", h)
	for f in fieldnames(MSA)
		h = hash(getfield(msa, f), h)
	end
	return h
end

function url(msa::MSA)
	"https://pfam.xfam.org/family/$(msa.id)/alignment/full/format?" *
		"format=$(msa.format)&" *
		"alnType=$(msa.aln)&" *
		"order=$(msa.order)&" *
		"case=$(msa.case)&" *
		"gaps=$(msa.gaps)&" *
		"download=1"
end

file(msa::MSA) = "pfam_$(msa.id).txt"

function LocalStore.save(msa::MSA, dir::String)
    save_opt = get(ENV, "JULIA_NO_VERIFY_HOSTS", nothing)
    ENV["JULIA_NO_VERIFY_HOSTS"] = "pfam.xfam.org"
	out = Downloads.download(url(msa), joinpath(dir, file(msa)))
    ENV["JULIA_NO_VERIFY_HOSTS"] = save_opt
    return out
end

function LocalStore.load(msa::MSA, dir::String)
	df = DataFrame(uniprot_id = String[], start = Int[], stop = Int[], sequence = String[])
	FastaReader(joinpath(dir, file(msa))) do fr
		for (desc, seq) in fr
			id, start, stop = split(desc, ['>', '/', '-']; keepempty=false)
			push!(df, (id, parse(Int, start), parse(Int, stop), seq))
		end
	end
	return df
end

"""
	load(msa)

Loads an MSA.
"""
function load(
    msa::MSA;
	inserts::Bool = false,	# set to false to remove inserts
    taxonomy::Bool = false,	# set to true to add taxonomy column
)
	df = LocalStore.load(msa)
	inserts || (df.sequence = remove_inserts.(df.sequence))
	if taxonomy
		tax = LocalStore.load(Taxonomy(msa))
		df.taxonomy = tax.taxonomy
	end
	return df
end

"""
	remove_inserts(sequence)

Remove inserts from a string sequence.
"""
function remove_inserts(sequence::String)
	filter(c -> c == '-' || c ≠ lowercase(c), sequence)
end
