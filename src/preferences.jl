const PFAM_DIR_KEY = "PFAM_DIR"
const PFAM_VERSION_KEY = "PFAM_VERSION"

"""
    set_pfam_directory(dir)

Set the directory where downloaded Pfam files are cached.

`dir` must already exist.
"""
function set_pfam_directory(dir)
    if isdir(dir)
        @set_preferences!(PFAM_DIR_KEY => dir)
        @info "PFAM directory $dir set."
    else
        throw(ArgumentError("Invalid directory path: $dir"))
    end
end

"""
    get_pfam_directory()

Return the configured directory where downloaded Pfam files are stored.
"""
function get_pfam_directory()
    dir = @load_preference(PFAM_DIR_KEY)
    if isnothing(dir)
        error("$PFAM_DIR_KEY not set; use `set_pfam_directory` to set it")
    else
        return dir
    end
end

"""
    set_pfam_version(version)

Set the Pfam release version used to build download URLs and cache paths.
"""
function set_pfam_version(version)
    @set_preferences!(PFAM_VERSION_KEY => version)
    @info "Pfam version $version set."
end

"""
    get_pfam_version()

Return the configured Pfam release version.
"""
function get_pfam_version()
    version = @load_preference(PFAM_VERSION_KEY)
    if isnothing(version)
        error("$PFAM_VERSION_KEY not set; use `set_pfam_version` to set it")
    else
        return version
    end
end
