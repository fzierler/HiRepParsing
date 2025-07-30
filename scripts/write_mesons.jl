using Pkg; Pkg.activate("."); Pkg.instantiate()
using HiRepParsing
using HDF5
using DelimitedFiles
using HiRepOutputCleaner

# This script parses the log files in the directory 'dir', and saves them as an hdf5-file 
# in the location provided by 'h5file'.

# It creates a single hdf5 file for all log files. Measurements performed on the same ensemble
# are written in distinct hdf5 groups labelled  by the variable `ensemble`
function main(listfile,h5file;setup=true,filter_channels=false,channels=nothing)
    isfile(h5file) && rm(h5file)
    for file in readdlm(listfile)
        @show file
        # use HiRepOutputCleaner by default
        tmp_filename = "tmp.txt"
        clean_hirep_file(file,tmp_filename;checkpoint_pattern="analysed")
        # only try parsing if the filesize is non-vanishing
        if filesize(tmp_filename) > 0
            ensemble = match(r"Lt[0-9]+Ls[0-9]+beta[0-9]+.[0-9]+mas-[0-9]+.[0-9]+FUN",file).match
            smearing_regex = r"source_N[0-9]+_sink_N[0-9]+"
            writehdf5_spectrum_with_regexp(tmp_filename,h5file,smearing_regex;mixed_rep=false,h5group=ensemble,setup,filter_channels,channels,sort=true)
        end
        rm(tmp_filename)
    end
end
main(ARGS[1],ARGS[2])

