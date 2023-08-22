#!python3

# reads .def files
# identifies which are VISIBLE tests (formerly gateway-quiz)
# verifies problem files actually exist
# and that groups actually contain that number of problems.

# assumptions: 
# problem set definitions are relatively root, and have suffix `.def`.  
# all .def files present are ones you want to process.  there is no skipping mechanism!
# if a set name start with "group", then it's a collection of problems used elsewhere, and even if it's a "gateway", it's not processed for validation
# 

###########  ⚠️ the "visible" property is NOT in the .def file. it's held somewhere else in non-exportable format.  so...  you have to make sure that no not-visible tests are in here 
# ⚠️ YET, you can't just export all visible sets and not export any invisible sets, because the problem groups are almost certainly invisible. ah, webwork.


test_type_name = "gateway" # i can imagine this will change someday?  they changed the name in the online interface, but it remains gateway under the hood.


from os import listdir
from os.path import isfile, join, exists
import os
import pandas as pd
import numpy as np
import logging
import shutil
import json
from collections import defaultdict
import pathlib


import datetime
today = datetime.datetime.now()

import pathlib







#############functions


def logging_setup():

    if not exists('logs'):
        os.mkdir('logs')

    logging.basicConfig(filename=f'logs/validate_results_{today}.log', encoding='utf-8', level=logging.DEBUG, format='%(levelname)s:\n%(message)s')





def get_set_type(source_as_lines):
    for line in source_as_lines:
        if 'assignmentType' in line:
            return line.split('=')[1].strip()

    raise RuntimeError('failed to find an assignmentType')



def parse_set(s):
    with open(s,'r') as f:
        source = f.read()

    set_info_this = {}

    problem_paths_this = None


    # parse the header, before the problem list
    header = source.split('problemList')[0].split('\n')
    properties_this = {}
    for line in header:
        if line:
            k,v = [t.strip() for t in line.split('=')]
        properties_this[k] = v



    found_problems = False # a flag for telling if we've already entered the problem list, JUST IN Case a set def file has more than one (would cause errors, and this was easy to program)
    # parse the problem list
    for n,ell in enumerate(source.split('\n')):

        if ell.startswith('problemListV2'): # probably unnecessary, but hey, implicit assumptions are the devil
            if found_problems:
                raise RuntimeError('already found problem list, but here we are again')
                
            set_info_this['def_version'] = 2
            problem_paths_this = [p.split(' = ')[1].strip() for p in source.split('\n')[n+1:] if p.startswith('source_file')]
            problem_specs_this = [p[:p.find('problem_end')] for p in source.split('problem_start')[1:]]

            found_problems = True

            break
        elif ell.startswith('problemList'):
            problem_paths_this = [p.split(',')[0] for p in source[n+1:] if '.pg' in p]
            set_info_this['def_version'] = 1

            raise NotImplemented("arst")

    set_info_this['def_file_name'] = s.name
    set_info_this['def_file_path'] = s
    set_info_this['def_file_source'] = source # the whole source.  may need this for text replacement if editing the set
    set_info_this['settings'] = properties_this  # this is a dictionary
    set_info_this['problem_paths'] = problem_paths_this # this got split out the loop above.  it should be a list.
    set_info_this['problem_specs'] = problem_specs_this # this got split out the loop above.  it should be a list.

    return set_info_this




def get_problems_by_set(sets):

    logging.debug(f'finding problems by set')

    problem_set_info = {}


    for s in sets:
        problem_set_info[s.stem[3:]] = parse_set(s) # drop the suffix, that's going to make this annoying

        
    return problem_set_info










folder = "templates"


templates = pathlib.Path(folder)

all_emoji = []


all_def_names = [f for f in templates.rglob("*.def")]
not_group_def_names = [f for f in templates.rglob("*.def") if not f.name.startswith('setgroup')]
group_def_names = [f for f in templates.rglob("*.def") if f.name.startswith('setgroup')]


test_def_names = []
for s in not_group_def_names:

    with open(s,'r') as file:
        source = file.readlines()
    set_type = get_set_type(source)

    if set_type == test_type_name:
        test_def_names.append(s)
    else:
        pass # skip, not a test type


all_sets = get_problems_by_set(all_def_names)
group_sets = get_problems_by_set(group_def_names)
test_sets = get_problems_by_set(test_def_names)

# this is impossible to compute::::  the visible property IS NOT IN THE .def FILE
#visible_tests = {name: data for name,data in test_sets.items() if data['']}




############ 🔥 i'm just doing one now, then i'll convert to a function

for name,data in test_sets.items():

    if len(data['problem_paths'])==0:
        continue


    # print(name)
    # print(data)
    # print(f'\n\n\nworking on {name}\n\n')

    problem_list = data['problem_paths']
    # print(problem_list)


    # now to parse the specific problems out and make sure they exist
    specific_problems = []
    group_problem_counts = defaultdict(int)
    problematic_problems = []

    for path in problem_list:
        if path.startswith('group') and not path.startswith('group:'):
            problematic_problems.append(path)

        elif path.startswith('group:'):
            group_problem_counts[path[6:]] += 1

        else:
            specific_problems.append(path)

    # print(specific_problems)
    # print(group_problem_counts)
    # print(problematic_problems)

    # deal with always-used problems
    for path in specific_problems:
        if not exists(join(folder,path)):
            raise NotImplementedError()


    # deal with problems from a group
    for path,num_needed in group_problem_counts.items():
        try:
            referred_set = group_sets[path]
        except:
            print(f'🔥 set {name} refers to group {path} that does not exist')
            continue


        num_have = len(referred_set['problem_paths'])
        if num_have < num_needed:
            print(f'🔥 insufficient problems in {path}, used by {name}.  need {num_needed}, but have only {num_have}')
        else:
            pass # all good 👍



    # deal with problematic problems
    for path in problematic_problems:
        print(f'🔥 problematic "group" problem path `{path}` used by {name}.  be sure to use `group:` to refer to problems from another set')









