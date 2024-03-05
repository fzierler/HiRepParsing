function _write_lattice_setup(file,h5file;mixed_rep=false,h5group="")
    # save other relevant quantities
    h5write(h5file,joinpath(h5group,"plaquette"),plaquettes(file))
    h5write(h5file,joinpath(h5group,"configurations"),confignames(file))
    h5write(h5file,joinpath(h5group,"gauge group"),gaugegroup(file))
    h5write(h5file,joinpath(h5group,"beta"),inverse_coupling(file))
    h5write(h5file,joinpath(h5group,"lattice"),latticesize(file))
    # get smearing parameters (arrays are empty if no smearing is used)
    APE_eps, APE_level = APE_smearing(file)
    Wuppertal_eps_anti, Wuppertal_eps_fund = Wuppertal_smearing_mixed(file)
    h5write(h5file,joinpath(h5group,"APE_eps"),APE_eps)
    h5write(h5file,joinpath(h5group,"APE_level"),APE_level)
    h5write(h5file,joinpath(h5group,"Wuppertal_eps_anti"),Wuppertal_eps_anti)
    h5write(h5file,joinpath(h5group,"Wuppertal_eps_fund"),Wuppertal_eps_fund)
    # special case fermion masses for mixed representations
    if !mixed_rep
        h5write(h5file,joinpath(h5group,"quarkmasses"),quarkmasses(file))
    else
        mf, mas = quarkmasses_chimera(file)
        h5write(h5file,joinpath(h5group,"quarkmasses_fundamental"),mf)
        h5write(h5file,joinpath(h5group,"quarkmasses_antisymmetric"),mas)
    end
end

function writehdf5_spectrum_disconnected(file,h5file,type::AbstractString,nhits;h5group="",setup=true,mixed_rep=false,h5group_setup = h5group)
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup)
    setup && h5write(h5file,joinpath(h5group_setup,"sources"),nhits)
    # read correlator data
    c = parse_spectrum(file,type;disconnected=true,nhits)
    # write matrices to file
    for Γ in keys(c)
        label = joinpath(h5group,type,Γ)
        h5write(h5file,label,c[Γ])
    end
end

function writehdf5_spectrum(file,h5file,type::AbstractString;h5group="",setup=true,mixed_rep=false,h5group_setup = h5group)
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup)
    # read correlator data
    c = parse_spectrum(file,type;disconnected=false)
    # write matrices to file
    for Γ in keys(c)
        label = joinpath(h5group,type,Γ)
        h5write(h5file,label,c[Γ])
    end
end

function writehdf5_spectrum_disconnected(file,h5file,types::Array{T},nhits;h5group="",setup=true,mixed_rep=false,h5group_setup = h5group) where T <: AbstractString
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup)
    setup && h5write(h5file,joinpath(h5group_setup,"sources"),nhits)
    for type in types
        # read correlator data
        c = parse_spectrum(file,type;disconnected=true,nhits)
        # write matrices to file
        for Γ in keys(c)
            label = joinpath(h5group,type,Γ)
            h5write(h5file,label,c[Γ])
        end
    end
end

function writehdf5_spectrum(file,h5file,types::Array{T};h5group="",setup=true,mixed_rep=false, h5group_setup = h5group) where T <: AbstractString
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup)
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