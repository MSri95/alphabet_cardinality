using DelimitedFiles
using Statistics
using Combinatorics
using LinearAlgebra
using Random


index=parse(Int64,ARGS[1])
RAW=ARGS[2]
land=ARGS[3]


f=readdlm(land)
if land!="input.tsv"
  f[4413,1]="NAN"
  f[3026,1]="INF"
end

w = Dict{String,Float64}()

for i in collect(2:1:size(f)[1])
    w[f[i,1]]=f[i,2]
end

L=length(f[2,1])



alphabet= ['A', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'Y']

mean_fit_reached = Array{Any,1}(undef,0)
var_fit_reached = Array{Any,1}(undef,0)
num_peaks_reached = Array{Any,1}(undef,0)
ht_peaks_reached = Array{Any,1}(undef,0)
mean_path_length = Array{Any,1}(undef,0)


write("basins_samepeaks_par_$(index)_land=$(land).txt","")

if land=="map_ParE2.tsv"
  ini = ['E','L','K','Q','I','P','N','W','S']
elseif land=="map_ParE3.tsv"
  ini= ['D','W', 'E','Y','K','S','G','P', 'F']
end


for j in collect(1:1:(20-length(ini)))

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

                    seq=s1*s2*s3; stop = 0; len=0
                    #println("ini seq is $seq")
                    while stop==0
                    #for steps in collect(1:1:10)
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
				seq_reached = vcat(seq_reached, seq)
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
    file=open("basins_samepeaks_par_$(index)_land=$(land).txt", "a")
    writedlm(file,B)
    
    close(file)

end



rrr= hcat(mean_fit_reached, var_fit_reached, num_peaks_reached, ht_peaks_reached, mean_path_length)

writedlm("growing_alphabets_samepeaks_mean_var_$(index)_RAW=$(RAW)_land=$(land).txt",rrr)
