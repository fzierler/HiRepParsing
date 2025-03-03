using Pkg; Pkg.activate("home/fabian/.julia/dev/HiRepParsing")
using HiRepParsing
using HDF5
using DelimitedFiles

# This script parses the log files in the directory 'dir', and saves them as an hdf5-file 
# in the location provided by 'h5file'.

# It creates a single hdf5 file for all log files. Measurements performed on the same ensemble
# are written in distinct hdf5 groups labelled  by the variable `ensemble`
function main(listfile,h5file;setup=true,filter_channels=false,channels=nothing,use_regex_parsing=true)
    for file in readdlm(listfile)
        ensemble = match(r"Lt[0-9]+Ls[0-9]+beta[0-9]+.[0-9]+mas-[0-9]+.[0-9]+FUN",file).match
        smearing_regex = r"source_N[0-9]+_sink_N[0-9]+"
        writehdf5_spectrum_with_regexp(file,h5file,smearing_regex;smearing=true,mixed_rep=false,h5group=ensemble,setup,filter_channels,channels,sort=true)
    end
end
main(ARGS[1],ARGS[2])

