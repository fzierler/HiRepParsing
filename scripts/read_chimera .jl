using HDF5

file = "/home/fabian/Downloads/lsd_out_new.hdf5"

io = h5open(file)

read(io,"quarkmasses_antisymmetric")
read(io,"quarkmasses_fundamental")
read(io,"APE_eps")
read(io,"APE_level")
read(io,"Wuppertal_eps_anti")
read(io,"Wuppertal_eps_fund")
read(io,"configurations")
read(io,"source_N40_sinkN80/Chimera_even_re")
close(io)