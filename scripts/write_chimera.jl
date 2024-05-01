using HiRepParsing
using HDF5

dir = "/home/fabian/Documents/DataDiaL/LSD"
h5file = "/home/fabian/Downloads/chimera_data_full_compression.hdf5"

function main(dir,h5file)

    group0 = "" 

    for file in readdir(dir,join=true)
        endswith(file,".txt") || continue

        regex = r"N(?<N1>[0-9]+)_N(?<N2>[0-9]+)"
        m = match(regex,basename(file))
        N1 = parse(Int,m[:N1])
        N2 = parse(Int,m[:N2])

        name  = first(splitext(basename(file)))

        group = replace(name,"N$(N1)_N$(N2)"=>"")
        types = ["source_N$(N1)_sink_N$N" for N in 0:10:N2]

        setup  = group != group0
        group0 = group
        @show group, setup 

        writehdf5_spectrum(file,h5file,types;mixed_rep=true,h5group=group,setup,compress=6,shuffle=(),chunk=(100,48))
    end
end

main(dir,h5file)