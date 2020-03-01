using HTTP

"""
	pfam_dir()

Directory where alignments will be stored.
"""
pfam_dir() = joinpath(first(DEPOT_PATH), "Pfam")

function download_file(obj)
	if !isfile(localpath(obj))
		println("Downloading ", url(obj))
		mkpath(dirname(localpath(obj)))
		HTTP.download(url(obj), localpath(obj))
	end
	return localpath(obj)
end

"""
	clean()

Removes all data files from the Pfam directory.
"""
clean() = rm(pfam_dir(), recursive=true)
