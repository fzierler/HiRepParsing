using HDF5

path = "/home/fabian/Downloads"
path = "/media/fabian/Paul/output_file/hdf5/"
file = "chimera_out_56x36x36x36b6.45mas1.04mf0.718_APE0.4N50_smf0.24as0.16N80_N80_s1.hdf5"
file = joinpath(path,file)

io = h5open(file)["M1"]

read(io,"quarkmasses_antisymmetric")
read(io,"quarkmasses_fundamental")
read(io,"APE_eps")
read(io,"APE_level")
read(io,"Wuppertal_eps_anti")
read(io,"Wuppertal_eps_fund")
read(io,"configurations")
read(io,"source_N40_sinkN80/Chimera_even_re")
close(io)