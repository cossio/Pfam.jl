using GaussDCA

#module ReWeight # from GaussDCA

const PACKBITS = 64
const _u = 0x0084210842108421
const _alt = 0x007c1f07c1f07c1f
const packfactor = div(PACKBITS, 5)
const packrest = PACKBITS % 5
const _msk = ~(UInt64(0));

clength(l::Int) = div(l-1, packfactor) + 1
crest(l::Int)   = (l-1) % packfactor + 1
nnz_aux(x::UInt64) = ((x | (x >>> 1) | (x >>> 2) | (x >>> 3) | (x >>> 4)) & _u)
nz_aux(nx::UInt64) = (nx & (nx >>> 1) & (nx >>> 2) & (nx >>> 3) & (nx >>> 4) & _u)
nz_aux2(nx::UInt64, s) = nz_aux(nx) & (_msk >>> s)

function compress_Z(Z::Matrix{Int8})
    N, M = size(Z)
    ZZ = Vector{Int8}[Z[:,i] for i = 1:M]
    cl = clength(N)
    cZ = [zeros(UInt64, cl) for i=1:M]
    @inbounds for i = 1:M
        cZi = cZ[i]
        ZZi = ZZ[i]
        for k = 1:N
            k0 = div(k-1, packfactor)+1
            k1 = (k-1) % packfactor
            cZi[k0] |= (UInt64(ZZi[k]) << (5*k1))
        end
    end
    return cZ
end

function compute_weights(Z::Matrix{Int8}, q::Integer, theta::Real)
    @assert q ≤ 32
    N, M = size(Z)
    cZ = compress_Z(Z)
    return compute_weights(cZ, theta, N, M)
end

function compute_weights(cZ::Vector{Vector{UInt64}}, theta::Real, N::Int, M::Int)
    theta = Float64(theta)
    cl = clength(N)
    kmax = div(cl - 1, 31)
    rmax = (cl - 1) % 31 + 1
    Meff = 0.0
    W = ones(M)
    thresh = floor(theta * N)
    println("theta = $theta threshold = $thresh")
    if theta == 0
        println("M = $M N = $N Meff = $M")
        return W, Float64(M)
    end
    for i = 1:M-1
        cZi = unsafe(cZ[i])
        for j = i+1:M
            cZj = unsafe(cZ[j])
            czi = start(cZi)
            czj = start(cZj)
            dist::UInt64 = 0
            z::UInt64 = 0
            for k = 1:kmax
                z = 0
                for r = 1:31
                    zi, czi = next(cZi, czi)
                    zj, czj = next(cZj, czj)
                    y = zi ⊻ zj
                    z += nnz_aux(y)
                end
                t = @collapse(z)
                dist += t
                dist >= thresh && break
            end
            if dist < thresh
                z = 0
                for r = 1:rmax
                    zi, czi = next(cZi, czi)
                    zj, czj = next(cZj, czj)

                    y = zi ⊻ zj
                    z += nnz_aux(y)
                end
                t = @collapse(z)
                dist += t
            end
            if dist < thresh
                W[i] += 1
                W[j] += 1
            end
        end
    end
    for i = 1:M
        W[i] = 1 / W[i]
    end
    Meff = sum(W)
    println("M = $M N = $N Meff = $Meff")
    return W, Meff
end


function ReadFasta(filename::AbstractString,
                   max_gap_fraction::Real = 0.9,
                   theta::Any = :auto,
                   remove_dups::Bool=true)

    Z = GaussDCA.read_fasta_alignment(filename, max_gap_fraction)
    if remove_dups
        Z, _ = GaussDCA.remove_duplicate_seqs(Z)
    end

    N, M = size(Z)
    q = round(Int,maximum(Z))

    q > 32 && error("parameter q=$q is too big (max 31 is allowed)")
    W, Meff = GaussDCA.compute_weights(Z, q, theta)

    rmul!(W, 1.0/Meff)
    Zint = round.(Int,Z)
    return W, Zint,N,M,q
end


filename = "/home/cossio/Desktop/julia/test.fasta"
max_gap_fraction = 0.9
theta = :auto
remove_dups = true


Z = GaussDCA.read_fasta_alignment(filename, max_gap_fraction)
if remove_dups
    Z, _ = GaussDCA.remove_duplicate_seqs(Z)
end


N, M = size(Z)
q = round(Int,maximum(Z))

q > 32 && error("parameter q=$q is too big (max 31 is allowed)")
W, Meff = GaussDCA.compute_weights(Z, q, 0.1)

W ./= Meff

#rmul!(W, 1.0/Meff)
Zint=round.(Int,Z)

cZ = compress_Z(Z)

x = GaussDCA.ReadFastaAlignment.letter2num('A')




ReadFasta("/home/cossio/Desktop/julia/test.fasta")
