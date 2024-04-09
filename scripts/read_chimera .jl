using HDF5

file = "/home/fabian/Downloads/data.hdf5"

io = h5open(file,"r")
io = io["runsSp4/Lt36Ls28beta7.2m1-0.794m2-0.794/out_spectrum"]

names = read(io,"configurations")
permutation_names(names)