import Pfam
import Preferences
using Test: @test, @test_throws, @testset

const download_calls_ref = Ref(Tuple{String, String}[])
const gunzip_calls_ref = Ref(String[])

function mock_download_helpers!()
    @eval Pfam begin
        function download_progress(url, path; timeout = Inf)
            push!($download_calls_ref[], (String(url), String(path)))
            write(path, "compressed")
            return nothing
        end

        function gunzip(file)
            file = String(file)
            push!($gunzip_calls_ref[], file)
            write(replace(file, r"\.gz$" => ""), "decompressed")
            rm(file; force = true)
            return nothing
        end
    end
end

original_pfam_dir = Preferences.load_preference(Pfam, Pfam.PFAM_DIR_KEY)
original_pfam_version = Preferences.load_preference(Pfam, Pfam.PFAM_VERSION_KEY)

try
    @testset verbose = true "pfam" begin
        @testset "preferences" begin
            Preferences.set_preferences!(Pfam, Pfam.PFAM_DIR_KEY => nothing; force = true)
            @test_throws ErrorException Pfam.get_pfam_directory()

            Preferences.set_preferences!(Pfam, Pfam.PFAM_VERSION_KEY => nothing; force = true)
            @test_throws ErrorException Pfam.get_pfam_version()

            missing_dir = joinpath(mktempdir(), "missing")
            @test_throws ArgumentError Pfam.set_pfam_directory(missing_dir)

            pfam_dir = mktempdir()
            Pfam.set_pfam_directory(pfam_dir)
            Pfam.set_pfam_version("35.0")
            @test Pfam.get_pfam_directory() == pfam_dir
            @test Pfam.get_pfam_version() == "35.0"
        end

        @testset "path helpers" begin
            pfam_dir = mktempdir()
            Pfam.set_pfam_directory(pfam_dir)
            Pfam.set_pfam_version("99.9")

            @test Pfam.base_url() == "https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam99.9"
            @test Pfam.base_url(; pfam_version = "12.0") ==
                  "https://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam12.0"

            version_path = Pfam.version_dir()
            @test version_path == joinpath(pfam_dir, "99.9")
            @test isdir(version_path)

            alignment_path = Pfam.alignment_files_dir()
            @test alignment_path == joinpath(pfam_dir, "alignment_files")
            @test isdir(alignment_path)
        end

        @testset "download helpers" begin
            mktempdir() do tmpdir
                source = joinpath(tmpdir, "source.txt")
                target = joinpath(tmpdir, "target.txt")
                write(source, "payload")
                Pfam.download_progress("file://$source", target)
                @test read(target, String) == "payload"

                plain = joinpath(tmpdir, "plain.txt")
                write(plain, "gzip payload")
                run(`$(Pfam.Gzip_jll.gzip()) -kf $plain`)
                rm(plain)
                Pfam.gunzip("$plain.gz")
                @test read(plain, String) == "gzip payload"
                @test !isfile("$plain.gz")
            end
        end

        @testset "dataset download functions" begin
            mock_download_helpers!()
            download_calls_ref[] = Tuple{String, String}[]
            gunzip_calls_ref[] = String[]
            download_calls = download_calls_ref[]
            gunzip_calls = gunzip_calls_ref[]

            cases = (
                ("pdbmap", (pfam_dir, pfam_version) -> Pfam.pdbmap(; pfam_dir, pfam_version), "pdbmap", "pdbmap.gz"),
                ("Pfam_A_hmm_dat", (pfam_dir, pfam_version) -> Pfam.Pfam_A_hmm_dat(; pfam_dir, pfam_version), "Pfam-A.hmm.dat", "Pfam-A.hmm.dat.gz"),
                ("Pfam_A_hmm", (pfam_dir, pfam_version) -> Pfam.Pfam_A_hmm(; pfam_dir, pfam_version), "Pfam-A.hmm", "Pfam-A.hmm.gz"),
                ("Pfam_A_seed", (pfam_dir, pfam_version) -> Pfam.Pfam_A_seed(; pfam_dir, pfam_version), "Pfam-A.seed", "Pfam-A.seed.gz"),
                ("Pfam_A_full", (pfam_dir, pfam_version) -> Pfam.Pfam_A_full(; pfam_dir, pfam_version), "Pfam-A.full", "Pfam-A.full.gz"),
                ("Pfam_A_fasta", (pfam_dir, pfam_version) -> Pfam.Pfam_A_fasta(; pfam_dir, pfam_version), "Pfam-A.fasta", "Pfam-A.fasta.gz"),
                ("pfamseq", (pfam_dir, pfam_version) -> Pfam.pfamseq(; pfam_dir, pfam_version), "pfamseq", "pfamseq.gz"),
                ("uniprot", (pfam_dir, pfam_version) -> Pfam.uniprot(; pfam_dir, pfam_version), "uniprot", "uniprot.gz"),
            )

            for (name, call, basename, remote_name) in cases
                empty!(download_calls)
                empty!(gunzip_calls)
                pfam_dir = mktempdir()
                pfam_version = "77.7"
                local_path = joinpath(pfam_dir, pfam_version, basename)

                @testset "$name" begin
                    @test call(pfam_dir, pfam_version) == local_path
                    @test isfile(local_path)
                    @test download_calls == [(Pfam.base_url(; pfam_version) * "/$remote_name", "$local_path.gz")]
                    @test gunzip_calls == ["$local_path.gz"]
                    @test !isfile("$local_path.gz")

                    @test call(pfam_dir, pfam_version) == local_path
                    @test length(download_calls) == 1
                    @test length(gunzip_calls) == 1
                end
            end
        end

        @testset "alignment downloads" begin
            download_calls_ref[] = Tuple{String, String}[]
            gunzip_calls_ref[] = String[]
            download_calls = download_calls_ref[]
            gunzip_calls = gunzip_calls_ref[]

            for which in (:full, :seed, :uniprot)
                empty!(download_calls)
                empty!(gunzip_calls)
                pfam_dir = mktempdir()
                local_path = joinpath(pfam_dir, "alignment_files", "PF00013.alignment.$which.stk")
                url = "https://www.ebi.ac.uk/interpro/wwwapi/entry/pfam/PF00013/?annotation=alignment:$which&download"

                @testset "$which" begin
                    @test Pfam.alignment_file("PF00013", which; pfam_dir) == local_path
                    @test isfile(local_path)
                    @test download_calls == [(url, "$local_path.gz")]
                    @test gunzip_calls == ["$local_path.gz"]
                    @test !isfile("$local_path.gz")

                    @test Pfam.alignment_file("PF00013", which; pfam_dir) == local_path
                    @test length(download_calls) == 1
                    @test length(gunzip_calls) == 1
                end
            end
        end
    end
finally
    Preferences.set_preferences!(Pfam, Pfam.PFAM_DIR_KEY => original_pfam_dir; force = true)
    Preferences.set_preferences!(Pfam, Pfam.PFAM_VERSION_KEY => original_pfam_version; force = true)
end
