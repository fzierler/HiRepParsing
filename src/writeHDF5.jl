function _write_lattice_setup(file,h5file)
    # save other relevant quantities
    h5write(h5file,"plaquette",plaquettes(file))
    h5write(h5file,"configurations",confignames(file))
    h5write(h5file,"gauge group",gaugegroup(file))
    h5write(h5file,"beta",inverse_coupling(file))
    h5write(h5file,"quarkmasses",quarkmasses(file))
    h5write(h5file,"lattice",latticesize(file))
end

function writehdf5_spectrum_disconnected(file,h5file,type::AbstractString,nhits)
    _write_lattice_setup(file,h5file)
    h5write(h5file,"sources",nhits)
    # read correlator data
    c = parse_spectrum(file,type;disconnected=true,nhits)
    # write matrices to file
    for Γ in keys(c)
        h5write(h5file,Γ,c[Γ])
    end
end

function writehdf5_spectrum(file,h5file,type::AbstractString)
    _write_lattice_setup(file,h5file)
    # read correlator data
    c = parse_spectrum(file,type;disconnected=false)
    # write matrices to file
    for Γ in keys(c)
        h5write(h5file,Γ,c[Γ])
    end
end

function writehdf5_spectrum_disconnected(file,h5file,types::Array{T},nhits;h5group="",setup=true) where T <: AbstractString
    setup && _write_lattice_setup(file,h5file)
    setup && h5write(h5file,"sources",nhits)
    for type in types
        # read correlator data
        c = parse_spectrum(file,type;disconnected=true,nhits)
        # write matrices to file
        for Γ in keys(c)
            label = joinpath(h5group,type,Γ)
            h5write(label,label,c[Γ])
        end
    end
end

function writehdf5_spectrum(file,h5file,types::Array{T};h5group="",setup=true) where T <: AbstractString
    setup && _write_lattice_setup(file,h5file)
    # read correlator data
    for type in types
        c = parse_spectrum(file,type;disconnected=false)
        # write matrices to file
        for Γ in keys(c)
            label = joinpath(h5group,type,Γ)
            h5write(h5file,label,c[Γ])
        end
    end
end
function writehdf5_disconnected(file,h5file)
    _write_lattice_setup(file,h5file)
    # read correlator data
    c = parse_disconnected(file)
    # obtain number of hits from matrix
    k = first(collect(keys(c)))
    h5write(h5file,"sources",size(c[k])[2])
    # write matrices to file
    for Γ in keys(c)
        h5write(h5file,Γ,c[Γ])
    end
end