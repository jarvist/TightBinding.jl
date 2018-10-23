# HighSymmetryPath.jl - convenience routines for generating high-symmetry paths
# in k-space and plotting 'band structures'

export HighSymmetryPath, PlotHighSymmetryPath

# This is a standard route in reciprocal space for hexagonal cells
hcpspec=
"80  0     0      0         .57735  .33333    0        G amma to K
80  .57735 .33333 0         .57735   0        0        K to M
80  .57735 0      0          0       0        0        M to Gamma
80  0      0      0          0       0        0.30618  G amma to A (ideal c/a)
80  .57735 .33333 0         .57735   .33333   0.30618  K to H (ideal c/a)
80  .57735 .33333 0.30618   .57735   0        0.30618  H (ideal c/a) to L
80  .57735 0      0.30618    0       0        0.30618  L to A (ideal c/a)
80  0      0      0.30618   .57735   .33333   0.30618  A (ideal) to H (ideal)
"

rows(M::Matrix) = map(x->reshape(getindex(M, x, :), :, size(M)[2]), 1:size(M)[1])
columns(M::Matrix) = map(x->getindex(M, :, x), 1:size(M)[2])

function HighSymmetryPath(pathspec; BZstep=0.005)
    r=readdlm(IOBuffer(pathspec))

    K=[]
    points=[0]
    labels=[]
    point=0

    for l in rows(r)
        #println("line: $l ")
        N=l[1]
        kxa=l[2]; kya=l[3]; kza=l[4];
        kxb=l[5]; kyb=l[6]; kzb=l[7];

        # vector form
        ka=[kxa kya kza]
        kb=[kxb kyb kzb]
        #println("  ka: $ka kb: $kb")
    
        N=ceil(norm((kb-ka)/BZstep)) # Choose number of data points by size in BZ
        step=(kb-ka)/AbstractFloat(N)
        #println("N: $N  step: $step")

        println("Line from $kxa $kya $kza to $kxb $kyb $kzb with $N steps")
    
        for n=1:N
            k=ka + step*n
#           println("k: $k k[1]:",k[1])
            push!(K,JVecF(k[1],k[2],k[3]))
        end
   
        point+=N
        append!(points,point) # location of high symmetry point

        label=l[8] #- this is a bit rubbish, you almost always are going to need to write these yourself
        append!(labels,label) # label of high symmetry point
    end
    return K,points,labels
end

function PlotHighSymmetryPath(K,points,labels; N=4)
    # plot the resulting Band Structure
    K,points,labels = HighSymmetryPath(hcpspec)
    bands = TB.band_structure(K, nrltb, at)
    gr() # v. compact SVG (?) files in notebook viewer, but static
    default(size=(960,640)) #Plot canvas size
    #plotly() # nice for 'live' mouseover-able figures, but generates ENORMOUS ipython notebook save files, which don't generally work in the online viewer...

    #plot(bands, label="", xticks=(0:100:800, ["G","K","M","G","A/K","H","L","A","H"]) )
    #plot(bands, label="", xticks=(points,labels) ) # fully automtated --> a bit rubbish

    plot(bands, label="", xticks=(points,["G","K","M","G","A/K","H","L","A","H"]) )
    #plot(bands, label="", xticks=(points,labels) )

    hline!([eF],line=(1,:dash,:black),label="")
    hline!([0],line=(1,:dot,:black),label="")

    vline!(points, line=(0.5,:black),label="")

    # Restrict to +-N eV of the Fermi level
    eF = nrltb.potential.eF
    yaxis!(ylims=(eF-N,eF+N))
end
