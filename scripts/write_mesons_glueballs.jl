using Pkg; Pkg.activate("."); Pkg.instantiate()
using HiRepParsing
using HDF5
using DelimitedFiles

function main(listfile,h5file;setup=true,filter_channels=false,channels=nothing)
    isfile(h5file) && rm(h5file)
    for (ensemble,disc,nhits,file) in eachrow(readdlm(listfile,','))
        if disc == "disc"
            smearing_regex = r"DISCON_SEMWALL smear_N[0-9]+ SINGLET"
            writehdf5_spectrum_disconnected_with_regexp(file,h5file,smearing_regex,nhits;mixed_rep=false,h5group=ensemble,setup,filter_channels,channels,sort=true,deduplicate=true)
        else
            smearing_regex = r"source_N[0-9]+_sink_N[0-9]+ TRIPLET"
            writehdf5_spectrum_with_regexp(file,h5file,smearing_regex;mixed_rep=false,h5group=ensemble,setup,filter_channels,channels,sort=true,deduplicate=true)
        end

    end
end

main("input/listfile.txt","test.hdf5",filter_channels=false,channels=nothing)
