import sys
import random
import itertools
import math

aas = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T']

def gen_all_alphabets(chars, size):
	return(list(itertools.combinations(set(chars), size)))

def binom_coef(n,k):
	return math.factorial(n)/math.factorial(k)/math.factorial(n-k)

#####################
# parameters
alph_size = int(sys.argv[1])
maxNumAlphs = int(sys.argv[2])
inputFile = sys.argv[3]
outputFileAlph = sys.argv[4]

# global peak
with open(inputFile, 'r') as f:
	data = f.read().split("\n")

globalMax = ""
globalMaxVal = -1
for line in data:
	if line!="":
		if float(line.split()[1])>globalMaxVal:
			globalMax = line.split()[0]
			globalMaxVal = float(line.split()[1])
#print(globalMax + " " + str(globalMaxVal))
#globalMax = max(data, key=data.get)
mustContain = list(set(globalMax))	# these characters must be in the alphabet
aas = [aa for aa in aas if aa not in mustContain]
with open(outputFileAlph, 'w') as f:
	alphs = []
	if binom_coef(20-len(mustContain),alph_size-len(mustContain))<maxNumAlphs:
		# generate all alphabets of size alph_size
		if alph_size > len(mustContain):
			alphs = gen_all_alphabets(aas, alph_size-len(mustContain))
			alphs = [list(a) for a in alphs]
			alphs = [sorted(x+mustContain) for x in alphs]
			#print(alphs)
		else:
			alphs = [sorted(mustContain)]
		for a in alphs:
			f.write(''.join(a)+"\n")
	else:
		# generate random set of alphabets
		while len(alphs)<maxNumAlphs:
			new_alph = mustContain + random.sample(aas, alph_size - len(mustContain))
			new_alph.sort()
			if new_alph not in alphs:
				alphs.append(new_alph)
				f.write(''.join(new_alph)+"\n")


	
