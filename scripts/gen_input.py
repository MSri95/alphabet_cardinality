import sys

#####################
# parameters
inputFile = sys.argv[1]
alph = sys.argv[2]
outputFileSub = sys.argv[3]
outputAntipods = sys.argv[4]

with open(inputFile, 'r') as f:
	data = f.read().split("\n")

globalMax = ""
globalMaxVal = -1
for line in data:
	if line!="":
		if float(line.split()[1])>globalMaxVal:
			globalMax = line.split()[0]
			globalMaxVal = float(line.split()[1])

# subset the input data to only contain sequences consisting of the chosen aas
with open(outputFileSub, 'w') as f:
	for line in data:
		if line!="":
			if line[0] in alph and line[1] in alph and line[2] in alph and (line[3] in alph or line[3]=="\t"):
				f.write(line+"\n")
				
# generate the list of all antipodal sequences
with open(outputAntipods, 'w') as f:
	alph = list(alph)
	if len(globalMax)==4:
		for c1 in alph:
			if c1!=globalMax[0]:
				for c2 in alph:
					if c2!=globalMax[1]:
						for c3 in alph:
							if c3!=globalMax[2]:
								for c4 in alph:
									if c4!=globalMax[3]:
										f.write(''.join([c1,c2,c3,c4])+"\n")
	else:
		for c1 in alph:
			if c1!=globalMax[0]:
				for c2 in alph:
					if c2!=globalMax[1]:
						for c3 in alph:
							if c3!=globalMax[2]:
								f.write(''.join([c1,c2,c3])+"\n")