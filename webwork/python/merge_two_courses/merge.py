#!python3

# this code reads problem sets, and tries to find problem source code.



from os import listdir
from os.path import isfile, join, exists
import os
import pandas as pd
import numpy as np
import logging
import shutil
import json
from collections import defaultdict

def logging_setup():


	logging.basicConfig(filename='merge_results.log', encoding='utf-8', level=logging.DEBUG, format='%(levelname)s:\n%(message)s')

def get_set_names(folder):
	
	logging.debug(f'getting problem set names for {folder}')

	onlyfiles = [f for f in listdir(folder) if isfile(join(folder, f))]

	set_names = [f for f in onlyfiles if f.endswith('.def')]
	set_names.sort()
	return set_names


def get_problems_by_set(sets,folder):

	logging.debug(f'finding problems by set for {folder}')

	problem_set_info = defaultdict(dict)


	for s in sets:
		with open(join(folder,s),'r') as f:
			source = f.read()

		problem_paths_this = None
		for n,ell in enumerate(source.split('\n')):

			if ell.startswith('problemListV2'):

				problem_set_info[s]['def_version'] = 2
				problem_paths_this = [p.split(' = ')[1].strip() for p in source.split('\n')[n+1:] if p.startswith('source_file')]
				problem_specs_this = [p[:p.find('problem_end')] for p in source.split('problem_start')[1:]]

				# print(problem_specs_this[0])


			elif ell.startswith('problemList'):
				problem_paths_this = [p.split(',')[0] for p in source[n+1:] if '.pg' in p]
				problem_set_info[s]['def_version'] = 1

				raise NotImplemented("arst")

			

		problem_set_info[s]['settings'] = source.split('problemList')[0]
		problem_set_info[s]['problem_paths'] = problem_paths_this
		problem_set_info[s]['problem_specs'] = problem_specs_this

		
	return problem_set_info




def find_nonlocal_problems(problem_set_info,folder):
	""" modifies `problem_set_info`, adding two entries to each set's dict  """

	for s, probs in problem_set_info.items():

		nonlocal_problems_this = []
		local_problems_this = []

		for p in probs['problem_paths']:

			logging.debug(f'looking for {p} for set {s}')

			local_path = join(folder,'local',p)
			root_path = join(folder,p)

			logging.debug(f'    looking for {local_path}')
			if exists(local_path) or exists(root_path):
				local_problems_this.append(p)
			else:
				nonlocal_problems_this.append(p)

		problem_set_info[s]["nonlocal_problems"] = nonlocal_problems_this
		problem_set_info[s]["local_problems"] = local_problems_this




def find_problems_in_opl(problem_set_info, opl_folder = 'webwork-open-problem-library'):
	""" modifies `problem_set_info`, adding two entries to each set's dict  """


	

	for set_name,set_info in problem_set_info.items():

		problems_in_opl_this = []
		missing_problems_this = []

		for p in set_info['nonlocal_problems']:

			if exists(join(opl_folder,'OpenProblem'+p)):
				problems_in_opl_this.append(p)
			else:
				missing_problems_this.append(p)

		problem_set_info[set_name]['problems_in_opl'] = problems_in_opl_this
		problem_set_info[set_name]['missing_problems'] = missing_problems_this




def process(folder):

	logging.info('\n\n')
	logging.info(f'finding problems by set for {folder}')
	
	set_names = get_set_names(folder)
	logging.info('\n'.join(set_names))

	problem_set_info = get_problems_by_set(set_names,folder)


	find_nonlocal_problems(problem_set_info,folder)
	find_problems_in_opl(problem_set_info)

	print('local_problems: {}'.format(sum([len(p['local_problems']) for p in problem_set_info.values()])))
	print('nonlocal_problems: {}'.format(sum([len(p['nonlocal_problems']) for p in problem_set_info.values()])))
	print('    missing_problems: {}'.format(sum([len(p['missing_problems']) for p in problem_set_info.values()])))
	print('    problems_in_opl: {}'.format(sum([len(p['problems_in_opl']) for p in problem_set_info.values()])))

	return problem_set_info



def merge(destination_folder, source_folder, dry_run = True):

	logging.info(f'merging into {destination_folder} from {source_folder}')



	source_problem_set_info = process(source_folder)

	A1 = [q['local_problems'] for q in source_problem_set_info.values()]
	A2 = []
	for qwfp in A1:
		A2.extend(qwfp)

	with open('merged_local_problems.txt','w') as f:
		f.write('\n'.join(A2))

	destination_problem_set_info = process(destination_folder)


	with open('merge_map.json','r') as f:
		merge_map = json.load(f)


	logging.info(merge_map)

	result_folder = './merge_results'



	# first, set up results folder, since we want to leave the original folder in-tact
	logging.info(f'duplicating {destination_folder} to {result_folder}')
	
	if exists(result_folder):
		shutil.rmtree(result_folder, ignore_errors=True)
	shutil.copytree(destination_folder, result_folder)


	with open('destination_problem_set_info.json','w') as f:
		json.dump(destination_problem_set_info, f, indent=4)
	with open('source_problem_set_info.json','w') as f:
		json.dump(source_problem_set_info, f, indent=4)



	logging.info(f'merging sets')
	for dest_name, sources in merge_map["existing_sets"].items():

		merge_defs(dest_name, sources, destination_problem_set_info, source_problem_set_info, result_folder)
		copy_local_problems(sources, source_problem_set_info, result_folder, source_folder)


	logging.info(f'creating new sets')
	for dest, sources in merge_map["new_sets"].items():
		copy_defs(sources, result_folder, source_folder)
		copy_local_problems(sources, source_problem_set_info, result_folder, source_folder)



def copy_defs(sources, result_folder, source_folder):

	for source_name in sources:
		source_filename = join(source_folder, source_name)
		dest_filename = join(result_folder, source_name)
		logging.info(f'copying def file {source_filename} to {dest_filename}')
		shutil.copy2(source_filename,dest_filename) # using copy2 to attempt to preserve metadata

def merge_defs(dest_name, sources, destination_problem_set_info, source_problem_set_info, result_folder):
	
	dest_set = destination_problem_set_info[dest_name] # unpack via a ref
	result_specs = dest_set['problem_specs'] # copy the destination problem specs to destination, so that we can merge into it in a loop.
	# print('{}'.format(len(result_specs)))
	for source_name in sources:
		logging.info(f'merging set {source_name} into {dest_name}')
		source_set = source_problem_set_info[source_name] # unpack via a ref

		# print('{}'.format(len(source_set['problem_specs'])))

		merge_specs(result_specs, source_set)

	# print('{}'.format(len(result_specs)))

	# assemble final .def file for merged set
	result_def_name = join(result_folder,dest_name)
	def_file = dest_set['settings']
	def_file = def_file + problem_specs_to_def_v2(result_specs)

	# write to file
	logging.info(f'writing new .def file `{result_def_name}`')
	with open(result_def_name,'w') as f:
		f.write(def_file)



def copy_local_problems(sources, source_problem_set_info, result_folder, source_folder_name):
	for source_name in sources:
		source_set = source_problem_set_info[source_name] # unpack via a ref
		for p in source_set['local_problems']:
			source_filename = join(source_folder_name, p)
			dest_filename   = join(result_folder,p)
			logging.info(f'copying local problem from {source_filename} to {dest_filename}')

			

			import pathlib
			pathlib.Path(os.path.dirname(dest_filename)).mkdir(parents=True, exist_ok=True)

			with open(dest_filename,'w') as f:
				f.write("## this file copied from Chris Hlas's Math114 content, Summer 2022, by permission of Chris Hlas\n")
				f.write("## this automatic process executed by silviana amethyst\n")
				f.write(f"## original filename {p}\n\n")
				with open(source_filename,'r') as g:
					f.write(g.read())

				# f.write()
				# shutil.copy2(source_filename,dest_filename) # using copy2 to attempt to preserve metadata


def merge_specs(result_specs, source_set):
	# this is wrong, because the two may have duplicate problems
	result_specs.extend(source_set['problem_specs'])





def problem_specs_to_def_v2(specs):
	r = 'problemListV2\n'

	for p in specs:
		r = r + 'problem_start' + p + 'problem_end\n'


	# now adjust problem numbers to be consecutive
	r = r.split('\n')

	result = []
	problem_num = 0
	for ell in r:
		if 'problem_id = ' in ell:
			problem_num += 1
			result.append(f'{ell[:ell.find("=")+2]} {problem_num}')
		else:
			result.append(ell)

	return '\n'.join(result)



def canonicalize_problem_locations(folder):
	logging.info('canonicalizing problem locations for {folder}')




if __name__ == "__main__":

	logging_setup()



	folder_hlas = "from_hlas/114_Fall_2021_Hlas"
	folder_amethyst = 'mine_sp22/114_Spring_2022_Amethyst_cleaned_up'

	merge(destination_folder=folder_amethyst, source_folder=folder_hlas)


	folder_result = 'merge_results'
	process(folder_result)

	# canonicalize_problem_locations(folder_result)
