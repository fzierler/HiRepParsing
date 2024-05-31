using HiRepParsing
using HDF5

dir = expanduser("~/Documents/DataDiaL/LSD")
h5file = expanduser("~/Downloads/chimera_data.hdf5")

function main(dir,h5file)

    ensemble0 = "" 

    for file in readdir(dir,join=true)
        # ignore everything that is not a .txt file
        endswith(file,".txt") || continue        
        # parse the ensemble name from the filename 
        # Check if we need to write the lattice-setupparameters to hdf5 file
        # (If we only have one file per ensemble we could skip this entirely)
        ensemble = replace(name,r"N[0-9]+_N[0-9]+"=>"")
        setup     = ensemble != ensemble0
        ensemble0 = ensemble
        @show ensemble, setup 
        
        # use a suitable regular expression to filter out the correlator data
        regex = r"source_N[0-9]+_sink_N[0-9]+"
        writehdf5_spectrum_with_regexp(file,h5file,regex;mixed_rep=true,h5group=ensemble,setup)
    end
end

main(dir,h5file)