using HiRepParsing

dir = "/media/fabian/External SSD/ChimeraData/lsd_out"
h5file = "/home/fabian/Downloads/lsd_out_new.hdf5"

function main(dir,h5file)

    setup = false

    for file in readdir(dir,join=true)
        contains(file,".txt") || continue

        regex = r"N(?<N1>[0-9]+)_N(?<N2>[0-9]+)"
        m = match(regex,basename(file))
        N1 = parse(Int,m[:N1])
        N2 = parse(Int,m[:N2])

        name  = first(splitext(basename(file)))

        group = replace(name,"N$(N1)_N$(N2)"=>"")
        types = ["source_N$(N1)_sink_N$N" for N in 0:10:N2]
        writehdf5_spectrum(file,h5file,types;mixed_rep=true,h5group=group,setup)
        setup = false
    end
end

main(dir,h5file)