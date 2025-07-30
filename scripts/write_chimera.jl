using HiRepParsing
using HDF5

# This script parses the log files in the directory 'dir', and saves them as an hdf5-file 
# in the location provided by 'h5file'.

# It creates a single hdf5 file for all log files. Measurements performed on the same ensemble
# are written in distinct hdf5 groups labelled  by the variable `ensemble`

dir = expanduser("/home/fabian/Documents/Physics/Data/Chimera_Data_new/logs/")
h5file = expanduser("~/Downloads/CD_with_regex.hdf5")
use_regex_parsing = true

filter_channels=true
channels=readlines("input/channels_chimera.txt")

function main(dir,h5file;setup=true,filter_channels=false,channels=nothing)

    # I have defined a reference variable for the last saved ensemble.
    # If the ensemble changes, we save also information on the lattice setup (coupling, size, bare masses) 
    # to the hdf5 file. This is controlled by the option 'setup', which writes the parameters to the file
    # if 'setup == true'
    ensemble0 = "" 
    # (This is not very robust and depends o the naming scheme of the output files)

    # loop over all files in the directory
    for file in readdir(dir,join=true)

        # I am just making sure, that we only look at raw log files.
        # Any files that does not end with '.txt' is ignored
        endswith(file,".txt") || continue

        # set up a regular expression, that matches the measurement type and the different smearing levels.
        # Note that the steps in the smearing levels are hard-coded
        regex = r"N(?<N1>[0-9]+)_N(?<N2>[0-9]+)"
        m = match(regex,basename(file))
        N1 = parse(Int,m[:N1])
        N2 = parse(Int,m[:N2])
        name  = first(splitext(basename(file)))
        types = ["source_N$(N1)_sink_N$N" for N in ["0","40","80"]]
        
        # parse the ensemble name from the filename 
        # (again this depends strongly on the naming scheme)
        # Check if we need to write the lattice-setupparameters to hdf5 file
        ensemble = replace(name,"N$(N1)_N$(N2)"=>"")
        if !isempty(ensemble0)
            setup     = ensemble != ensemble0
        end
        ensemble0 = ensemble
        @show file
        @show ensemble, setup 
              
        ###################################################################################
        # Method A: Using a regular expression directly  (faster, but it uses more ram)   #
        ###################################################################################
        #####################################################
        # Method B: Using a list of types                   #
        #####################################################
        if use_regex_parsing
            regex = r"source_N[0-9]+_sink_N(0|40|80)"
            writehdf5_spectrum_with_regexp(file,h5file,regex;mixed_rep=true,h5group=ensemble,setup,filter_channels,channels,sort=true)
        else
            writehdf5_spectrum(file,h5file,types;mixed_rep=true,h5group=ensemble,setup,filter_channels,channels,sort=true)
        end

    end
end

main(dir,h5file;filter_channels,channels)