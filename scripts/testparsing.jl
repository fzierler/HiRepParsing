using Pkg; Pkg.activate(".")
using HiRepParsing

basepath = "/home/fabian/Documents/Lattice/HiRepDIaL/measurements/"
filename = "Lt48Ls20beta6.5mf0.71mas1.01AS"
filename = "Lt48Ls20beta6.5mf0.71mas1.01FUN"

path   = joinpath(basepath,filename,"out")
h5path = joinpath("/home/fabian/Documents/Lattice/HiRepDIaL/h5files",filename)
ispath(h5path) || mkpath(h5path)

# input files
file_spectrum = joinpath(path,"out_spectrum")
file_discon1  = joinpath(path,"out_spectrum_discon")
file_discon2  = joinpath(path,"out_disconnected")

# input files
h5file_spectrum = joinpath(h5path,"out_spectrum.h5")
h5file_discon1  = joinpath(h5path,"out_spectrum_discon.h5")
h5file_discon2  = joinpath(h5path,"out_disconnected.h5")

nhits    = 48
typeDISC = "DISCON_SEMWALL SINGLET"
typeCONN = "DEFAULT_SEMWALL TRIPLET"

writehdf5_spectrum(file_spectrum,h5file_discon1,typeCONN)
writehdf5_spectrum_disconnected(file_discon1,h5file_spectrum,typeDISC,nhits)
writehdf5_disconnected(file_discon2,h5file_discon2)
