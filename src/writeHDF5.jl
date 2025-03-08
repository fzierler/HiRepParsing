function permutation_names(names)
    numbers = parse.(Int,last.(split.(names,"n")))
    return sortperm(numbers)
end
unique_indices(v) = unique(i -> v[i], eachindex(v))
function _write_lattice_setup(file,h5file;mixed_rep=false,h5group="",sort=false,smearing=true,deduplicate=false)
    names, plaq = confignames_and_plaquette(file)
    perm  = sort ? permutation_names(names) : eachindex(names)
    inds  = deduplicate ? unique_indices(names[perm]) : eachindex(names[perm]) 
    plaq  = plaq[perm][inds]
    names = names[perm][inds]
    # save other relevant quantities
    h5write(h5file,joinpath(h5group,"plaquette"),plaq)
    h5write(h5file,joinpath(h5group,"configurations"),names)
    h5write(h5file,joinpath(h5group,"gauge group"),gaugegroup(file))
    h5write(h5file,joinpath(h5group,"beta"),inverse_coupling(file))
    h5write(h5file,joinpath(h5group,"lattice"),latticesize(file))
    # write information on the applied sorting and deduplication to file
    h5write(h5file,joinpath(h5group,"sorted"),sort)
    h5write(h5file,joinpath(h5group,"deduplicated"),deduplicate)
    h5write(h5file,joinpath(h5group,"sort_permutation"),perm)
    h5write(h5file,joinpath(h5group,"deduplicated_indices"),inds)
    # get smearing parameters (arrays are empty if no smearing is used)
    if smearing
        APE_eps, APE_level = APE_smearing(file)
        Wuppertal_eps_anti, Wuppertal_eps_fund = Wuppertal_smearing_mixed(file)
        h5write(h5file,joinpath(h5group,"APE_eps"),APE_eps)
        h5write(h5file,joinpath(h5group,"APE_level"),APE_level)
        h5write(h5file,joinpath(h5group,"Wuppertal_eps_anti"),Wuppertal_eps_anti)
        h5write(h5file,joinpath(h5group,"Wuppertal_eps_fund"),Wuppertal_eps_fund)
    end
    # special case fermion masses for mixed representations
    if !mixed_rep
        h5write(h5file,joinpath(h5group,"quarkmasses"),quarkmasses(file))
    else
        mf, mas = quarkmasses_chimera(file)
        h5write(h5file,joinpath(h5group,"quarkmasses_fundamental"),mf)
        h5write(h5file,joinpath(h5group,"quarkmasses_antisymmetric"),mas)
    end
end

function writehdf5_spectrum_disconnected(file,h5file,type::AbstractString,nhits;sort=false,h5group="",setup=true,mixed_rep=false,h5group_setup = h5group,filter_channels=false,channels=nothing, kws...)
    names = confignames(file)
    perm  = sort ? permutation_names(names) :  collect(eachindex(names))
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup,sort)
    setup && h5write(h5file,joinpath(h5group_setup,"sources"),nhits)
    # read correlator data
    c = parse_spectrum(file,type;disconnected=true,nhits,filter_channels,channels)
    # write matrices to file
    for Γ in keys(c)
        label = joinpath(h5group,type,Γ)
        filter_channels && Γ ∉ channels && continue
        sort && h5write(h5file,label,c[Γ][perm,:,:];kws...)
        sort || h5write(h5file,label,c[Γ];kws...)
    end
end

function writehdf5_spectrum(file,h5file,type::AbstractString;sort=false,h5group="",setup=true,mixed_rep=false,h5group_setup = h5group,filter_channels=false,channels=nothing, kws...)
    names = confignames(file)
    perm  = sort ? permutation_names(names) :  collect(eachindex(names))
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup,sort)
    # read correlator data
    c = parse_spectrum(file,type;disconnected=false,filter_channels,channels)
    # write matrices to file
    for Γ in keys(c)
        label = joinpath(h5group,type,Γ)
        filter_channels && Γ ∉ channels && continue
        sort && h5write(h5file,label,c[Γ][perm,:];kws...)
        sort || h5write(h5file,label,c[Γ];kws...)
    end
end

function writehdf5_spectrum_disconnected(file,h5file,types::Array{T},nhits;sort=false,h5group="",setup=true,mixed_rep=false,h5group_setup = h5group,filter_channels=false,channels=nothing, kws...) where T <: AbstractString
    names = confignames(file)
    perm  = sort ? permutation_names(names) :  collect(eachindex(names))    
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup,sort)
    setup && h5write(h5file,joinpath(h5group_setup,"sources"),nhits)
    dataset = h5open(h5file,"cw")
    @showprogress "Parse logfile for disconnected diagrams:" for type in types
        # read correlator data
        c = parse_spectrum(file,type;disconnected=true,nhits,with_progress=false,filter_channels,channels)
        # write matrices to file
        for Γ in keys(c)
            label = joinpath(h5group,type,Γ)
            filter_channels && Γ ∉ channels && continue
            sort && write(dataset,label,c[Γ][perm,:,:];kws...)
            sort || write(dataset,label,c[Γ];kws...)
        end
    end
    close(dataset)
end

function writehdf5_spectrum(file,h5file,types::Array{T};sort=false,h5group="",setup=true,mixed_rep=false, h5group_setup = h5group,filter_channels=false,channels=nothing, kws...) where T <: AbstractString
    names = confignames(file)
    perm  = sort ? permutation_names(names) :  collect(eachindex(names))
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup,sort)
    # read correlator data
    dataset = h5open(h5file,"cw")
    @showprogress "Parse logfile for connected diagrams:" for type in types
        c = parse_spectrum(file,type;disconnected=false,with_progress=false,filter_channels,channels)
        # write matrices to file
        for Γ in keys(c)
            label = joinpath(h5group,type,Γ)
            filter_channels && Γ ∉ channels && continue
            sort && write(dataset,label,c[Γ][perm,:];kws...)
            sort || write(dataset,label,c[Γ];kws...)
        end
    end
    close(dataset)
end
#####################################################
# Parsing using regular expressions (for smearing)  #
#####################################################
function writehdf5_spectrum_disconnected_with_regexp(file,h5file,rgx::Regex,nhits;sort=false,h5group="",setup=true,mixed_rep=false,h5group_setup = h5group,filter_channels=false,channels=nothing, kws...)
    names = confignames(file)
    perm  = sort ? permutation_names(names) :  collect(eachindex(names))    
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup,sort)
    setup && h5write(h5file,joinpath(h5group_setup,"sources"),nhits)

    # read correlator data
    c = parse_spectrum_with_regexp(file,rgx;disconnected=true,nhits,with_progress=true,filter_channels,channels)
    # write matrices to file
    dataset = h5open(h5file,"cw")
    for key in keys(c)
        type,Γ = splitpath(key)
        label = joinpath(h5group,type,Γ)
        filter_channels && Γ ∉ channels && continue
        sort && write(dataset,label,c[key][perm,:,:];kws...)
        sort || write(dataset,label,c[key];kws...)
    end
    close(dataset)
end
function writehdf5_spectrum_with_regexp(file,h5file,rgx::Regex;sort=false,h5group="",setup=true,mixed_rep=false, h5group_setup = h5group,filter_channels=false,channels=nothing, kws...)
    names = confignames(file)
    perm  = sort ? permutation_names(names) : collect(eachindex(names))
    setup && _write_lattice_setup(file,h5file;mixed_rep,h5group=h5group_setup,sort)

    # read correlator data
    c = parse_spectrum_with_regexp(file,rgx;disconnected=false,with_progress=true,filter_channels,channels)
    # write matrices to file
    dataset = h5open(h5file,"cw")
    for key in keys(c)
        type,Γ = splitpath(key)
        label  = joinpath(h5group,type,Γ)
        filter_channels && Γ ∉ channels && continue
        sort && write(dataset,label,c[key][perm,:];kws...)
        sort || write(dataset,label,c[key];kws...)
    end
    close(dataset)
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