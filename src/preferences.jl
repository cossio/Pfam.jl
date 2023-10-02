# Stores downloaded Pfam files
function set_pfam_directory(dir)
    if isdir(dir)
        @set_preferences!("PFAM_DIR" => dir)
        @info "PFAM directory $dir set."
    else
        throw(ArgumentError("Invalid directory path: $dir"))
    end
end

function get_pfam_directory()
    dir = @load_preference("PFAM_DIR")
    if isnothing(dir)
        error("PFAM_DIR not set; use `set_pfam_directory` to set it")
    else
        return dir
    end
end

# Define verison of Pfam to use
function set_pfam_version(version)
    @set_preferences!("PFAM_VERSION" => version)
    @info "Pfam version $version set."
end

function get_pfam_version()
    version = @load_preference("PFAM_VERSION")
    if isnothing(version)
        error("PFAM_VERSION not set; use `set_pfam_version` to set it")
    else
        return version
    end
end
