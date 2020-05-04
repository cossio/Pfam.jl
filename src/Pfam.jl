module Pfam
    #using DataDeps

    function __init__()
        pfam_db_deps = (
            ("uniprot", "0520f46b4788a41797fd688d76c0fc9ec4d98869ed7cc9543c83b49abf90272a"),
            ("pfamseq", "f15353053f4aeb7a3afa1d8ca720d33497c343d6b301ecdf149e2864a7703d04"),
        )

        for (db, checksum) in pfam_db_deps
            filename = "$db.txt.gz"
            url = "ftp://ftp.ebi.ac.uk/pub/databases/Pfam/releases/Pfam32.0/database_files/$filename"
            dp = DataDep(db,
                """
                Downloading this file from Pfam database:
                $url

                The Pfam protein families database in 2019:
                S. El-Gebali, J. Mistry, A. Bateman, S.R. Eddy, A. Luciani, S.C. Potter,
                M. Qureshi, L.J. Richardson, G.A. Salazar, A. Smart, E.L.L. Sonnhammer,
                L. Hirsh, L. Paladin, D. Piovesan, S.C.E. Tosatto, R.D. Finn
                Nucleic Acids Research (2019)
                doi: 10.1093/nar/gky995
                """,
                url, (sha256, checksum))
            register(dp)
        end
    end

    include("msa.jl")
    include("taxonomy.jl")
    include("util.jl")
end
