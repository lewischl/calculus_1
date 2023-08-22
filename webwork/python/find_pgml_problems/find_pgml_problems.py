from pathlib import Path

templates = Path('./templates')

problems_with_pgml = []

for f in templates.iterdir():
	if f.match('set*'):
		for g in f.iterdir():
			if g.match('*.pg'):
				with open(g) as problem_file:
					problem_source = problem_file.read()
					if 'BEGIN_PGML' in problem_source and "youtubeAmethyst" in problem_source:
						problems_with_pgml.append(g)


with open('problems_with_pgml.txt','w') as file:
	for p in problems_with_pgml:
		file.write(str(p).split('/',1)[1]+ '\n') 
