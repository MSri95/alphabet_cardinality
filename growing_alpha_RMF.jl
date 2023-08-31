using DelimitedFiles
using Statistics
using Combinatorics
using LinearAlgebra
using Random





a=20; L=4

alphabet = ['A', 'B','C', 'D', 'E', 'F', 'G', 'H', 'I', 'J','K', 'L', 'M', 'N', 'O','P', 'Q', 'R', 'S', 'T']

function all_seqs(a,L)
    alphabet = Char(65):Char(65+a-1)#Char(97):Char(97+a-1)
    return(join.(collect(Iterators.product(ntuple(_ -> alphabet, L)...))[:]))
end

function MF(a,L)
     w = Dict{String,Float64}()

     num = Dict{Char,Int64}()
     for i in collect(1:1:a)
        num[Char(97+i-1)]=i
     end

     s=all_seqs(a,L)
     w[s[1]]=0

    effects=zeros(Float64,a,L)
    for i in collect(1:1:L)
        for j in collect(2:1:a)
            effects[j,i]=rand()
        end
    end

    for i in collect(2:1:a^L)
        muts=zeros(Int64,L)
        for j in collect(1:1:L)
            if s[i][j]!=s[1][j]
                muts[j]=num[s[i][j]]
            end
        end

        w[s[i]]=0
        for j in collect(1:1:L)
            if muts[j]!=0
                w[s[i]]+=effects[muts[j],j]
            end
        end

    end


    return(w)
end

function RMF(mf,a,L,c,sid)
     ### Adding the roughness component ########
    s=all_seqs(a,L);
    rmf = Dict{String,Float64}()
   #Random.seed!(sid)
    rs=readdlm("rand_nos.txt")

    for i in collect(1:1:a^L)

        rmf[s[i]]=mf[s[i]]+c*rs[i]
    end

    wmax=rmf[argmax(rmf)]

    for i in collect(1:1:a^L)
        #mf[s[i]]/=wmax
    end

    return(rmf)
end





RAW=ARGS[1]
land=ARGS[2]
c=parse(Float64,ARGS[3])
sid =  parse(Int64,ARGS[4])
index=parse(Int64,ARGS[5])

write("basins_RMF_$(index)_land=$(land).txt","")

s=all_seqs(a,L)
mf=Dict{String,Float64}()


f=readdlm(land)

for i in collect(1:1:a^L)
	mf[f[i,1]]=f[i,2]
end

w=RMF(mf,a,L,c,sid)


f= Array{Any,2}(undef,a^L,2)
for i in collect(1:1:a^L)
	f[i,1] = s[i]
	f[i,2] = w[s[i]]
end


mean_fit_reached = Array{Any,1}(undef,0)
var_fit_reached = Array{Any,1}(undef,0)
num_peaks_reached = Array{Any,1}(undef,0)
ht_peaks_reached = Array{Any,1}(undef,0)
mean_path_length = Array{Any,1}(undef,0)


ini=unique(f[argmax(f[:,2]),1])


for j in collect(1:1:20-length(ini))

    println("alpha size is ", j)
    fit_reached = Array{Any,1}(undef,0)
    seq_reached = Array{Any,1}(undef,0)
    path_length = Array{Any,1}(undef,0)
    for i in collect(1:1:length(ini))
        global alphabet=filter!(e->e≠ini[i],alphabet)
    end

    global ini = vcat(ini,rand(alphabet))
    set=ini
    ####### RAW Sim #############

    for s1 in ini
        for s2 in ini
            for s3 in ini
                for s4 in ini
                    seq=s1*s2*s3*s4; len=0
                    stop = 0;
                    #println("ini seq is $seq")
                    while stop==0

                        mutants = Array{Any,1}(undef,0)### all mutants from a given sequence
                        fmuts = Array{Any,1}(undef,0)
                        for l in collect(1:1:L)
                            #set=ini
                            #println(ini)
                            #temp=filter!(e->e≠seq[l],set)
                            temp=ini
                            for mut in temp
                                if mut!=seq[l]
                                    new=collect(seq)
                                    new[l] = mut
                                    new = join(new)
                                    mutants=vcat(mutants,new)
                                    fmuts=vcat(fmuts, w[new])
                                end
                            end
                        end
                        if RAW == "greedy"

                          if maximum(fmuts)>w[seq]
                              seq=mutants[argmax(fmuts)]
                              len+=1
                              #println("next seq ", seq," ", w[seq])
                          else
                              #println("reached peak")
                              stop=1
                              fit_reached=vcat(fit_reached, w[seq])
                              seq_reached = vcat(seq_reached, seq)
                              path_length = vcat(path_length, len)
                          end

                        elseif RAW == "equal"

                            fit_muts=Array{Any,1}(undef,0)
                            for sam in mutants
                                if w[sam]>w[seq]
                                    fit_muts=vcat(fit_muts,sam)
                                end
                            end

                            if length(fit_muts)!=0
                                  seq=rand(fit_muts)
                                  len+=1
                            else
                                  stop=1
                                  fit_reached=vcat(fit_reached, w[seq])
                                  path_length = vcat(path_length, len)
                            end

			                elseif RAW == "corr"

                            fit_muts=Array{Any,1}(undef,0)
                            for sam in mutants
                                if w[sam]>w[seq]
                                    fit_muts=vcat(fit_muts,sam)
                                end
                            end

                            if length(fit_muts)!=0
                                  seq=rand(fit_muts)
                            else
                                  stop=1
                                  fit_reached=vcat(fit_reached, w[seq])
                            end

                       end
		  end


                end
            end
        end
    end
    global mean_fit_reached=vcat(mean_fit_reached,mean(fit_reached))
    global var_fit_reached=vcat(var_fit_reached,std(fit_reached))
    global num_peaks_reached = vcat(num_peaks_reached, length(unique(seq_reached)))
    global ht_peaks_reached = vcat(ht_peaks_reached, mean(unique(fit_reached)))
    global mean_path_length = vcat(mean_path_length, mean(path_length))
    
    B = [(count(==(o), seq_reached)) for o in unique(seq_reached)]
    B=transpose(B)
    file=open("basins_RMF_$(index)_land=$(land).txt", "a")
    writedlm(file,B)
    close(file)


end



rrr= hcat(mean_fit_reached, var_fit_reached, num_peaks_reached, ht_peaks_reached, mean_path_length)

writedlm("growing_alphabets2_mean_var_$(index)_RAW=$(RAW)_RMF=$(land)_c=$(c).txt",rrr)
