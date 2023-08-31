# alphabet_cardinality

Julia scripts for the topographical analysis and evolutionary simulations in the paper "Alphabet cardinality and adaptive evolution"

## 1. For analysing the RMF landscapes:

julia growing_alpha_RMF.jl type-of-random-adaptive-walk MF-landscape roughness-parameter seed repetition 

  PARAMETERS:
  - type-of-random-adaptive-walk: greedy or equal
  - MF-landscape: MF_L=4_$(i).txt ; text file containing Mt. Fuji landscape #i
  - roughness parameter: roughness parameter in the RMF model
  - seed: specifies the seed of the random number generator
  - repetition: specifies repetition number of the alphabet expansion (not the total number of repetitions)

## 2. For analysing the ParD-ParE landscapes:

julia growing_alpha_par.jl repetition type-of-random-adaptive-walk landscape

  PARAMETERS:
- repetition: specifies repetition number of the alphabet expansion (not the total number of repetitions)
- type-of-random-adaptive-walk: greedy or equal
- landscape: landscape file: map_ParE2.tsv or map_ParE3.tsv

## 3. For analysing the GB1 landscape:

julia growing_alpha_2.jl repetition type-of-random-adaptive-walk landscape

  PARAMETERS:
- repetition: specifies repetition number of the alphabet expansion (not the total number of repetitions)
- type-of-random-adaptive-walk: greedy or equal
- landscape: landscape file: map_GB1.tsv

  
  







