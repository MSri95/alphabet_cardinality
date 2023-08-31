# alphabet_cardinality

Julia scripts for the topographical analysis and evolutionary simulations in the paper "Alphabet cardinality and adaptive evolution"

1. For analysing the RMF landscapes:

julia growing_alpha_RMF.jl type-of-random-adaptive-walk MF-landscape roughness-parameter seed repetition 

  PARAMETERS:
  type-of-random-adaptive-walk: greedy, equal 
  MF-landscape: MF_L=4_$(i).txt ; text file containing Mt. Fuji landscape #i
  roughness parameter: roughness parameter in the RMF model 
  seed: specifies the seed of the random number generator 
  repetition: specifies repetition number of the alphabet expansion (not the total number of repetitions)
  







