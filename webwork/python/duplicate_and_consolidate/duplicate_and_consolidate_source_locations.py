#!python3

# this code reads problem sets, and tries to find problem source code.  
# it then moves source code and associated images into a folder for that homework set.  
# it will add lines to the tops of files documenting what it did.

# assumptions: 
# problem set definitions are relatively root, and have suffix `.def`.  
# all .def files present are ones you want to process.  there is no skipping mechanism!
# if a problem shows up as used in the OPL *and* as a local copy with the word "local" prepended, the "addlocal" version is updated and we should use it.  thus, if two problems in a set appear, one in OPL and one is addlocal, we canonicalize the the addlocal version and ignore the OPL version.

# there is a known bug, but i haven't put in the time to fix it yet.  it leaves the word "local" at the front of some problems in the .def file where it shouldn't.  

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


def logging_setup():

    if not exists('logs'):
        os.mkdir('logs')

    logging.basicConfig(filename=f'logs/consolidate_results{today}.log', encoding='utf-8', level=logging.DEBUG, format='%(levelname)s:\n%(message)s')



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

        problem_set_info[s]['set_name'] = s
        problem_set_info[s]['def_file_source'] = source # the whole source.  will need this for text replacement when move files.
        problem_set_info[s]['settings'] = source.split('problemList')[0]  # get stuff before "problemList", call it "settings""
        problem_set_info[s]['problem_paths'] = problem_paths_this # this got split out the loop above.  it should be a list.
        problem_set_info[s]['problem_specs'] = problem_specs_this # this got split out the loop above.  it should be a list.

        
    return problem_set_info




def find_nonlocal_problems(problem_set_info,folder):
    """ modifies `problem_set_info`, adding two entries to each set's dict  """

    for s, probs in problem_set_info.items():

        nonlocal_problems_this = []
        local_problems_this = []
        add_local_this = []

        for p in probs['problem_paths']:

            logging.debug(f'looking for {p} for set {s}')

            local_path_with_local_added = join(folder,'local',p)
            local_path_without_modification = join(folder,p)


            logging.debug(f'    looking for {p}')

            if exists(local_path_without_modification):
                local_problems_this.append(p)
            elif exists(local_path_with_local_added):
                add_local_this.append(p)
            else:
                nonlocal_problems_this.append(p)

        problem_set_info[s]["nonlocal_problems"] = nonlocal_problems_this
        problem_set_info[s]["local_problems"] = local_problems_this
        problem_set_info[s]["addlocal_problems"] = add_local_this






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




def get_folder_information(folder):

    logging.info('\n\n')
    logging.info(f'finding problems by set for {folder}')
    
    set_names = get_set_names(folder)
    logging.info('\n'.join(set_names))

    problem_set_info = get_problems_by_set(set_names,folder)


    find_nonlocal_problems(problem_set_info,folder) # this call modifies `problem_set_info`
    find_problems_in_opl(problem_set_info)          # this call modifies `problem_set_info`

    print('local_problems: {}'.format(sum([len(p['local_problems']) for p in problem_set_info.values()])))
    print('addlocal_problems: {}'.format(sum([len(p['addlocal_problems']) for p in problem_set_info.values()]))) # problems where if we add the word "local", we find a copy
    print('nonlocal_problems: {}'.format(sum([len(p['nonlocal_problems']) for p in problem_set_info.values()])))
    print('    missing_problems: {}'.format(sum([len(p['missing_problems']) for p in problem_set_info.values()])))
    print('    problems_in_opl: {}'.format(sum([len(p['problems_in_opl']) for p in problem_set_info.values()])))

    # for p in problem_set_info.values():
    #     print(p['set_name'],p['missing_problems'] )

    return problem_set_info






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




def copy_folder(source_folder, destination_folder):

    logging.info(f'duplicating {source_folder} to {destination_folder}')
    
    if exists(destination_folder):
        logging.info(f'removing previous instance of {destination_folder}')
        shutil.rmtree(destination_folder, ignore_errors=True)
    shutil.copytree(source_folder, destination_folder, symlinks=True)










def find_images(path):
    logging.info(f'finding images in {path}')
    path = pathlib.Path(path)
    images = []
    
    image_suffixes = ['png','gif','jpg','jpeg'] # dear lord i hope this is sufficient
    for f in path.iterdir():
        for s in image_suffixes:
            if str(f).lower().endswith(s):
                images.append(f)
                break # can only have one suffix, so this break is appropriate

    return images





def canonicalize_addlocal_problems(set_name, problems, destination_problem_set_folder, source_folder, destination_folder):
    # adds "local", replaces in source, moves to "local problems" list.

    if problems['addlocal_problems']:
        logging.info(f'{set_name} has addlocal problems!')
    else:
        return

    for p in set(problems['addlocal_problems']): # using a set so if a problem is listed twice it's ok!
        logging.info(f'\t{p} is an addlocal problem')

        addlocal_problem_name = join('local', p)

        problems['def_file_source'] = problems['def_file_source'].replace(p, addlocal_problem_name)
        problems['local_problems'].append(addlocal_problem_name)





def canonicalize_local_problems(set_name, problems, set_folder, source_folder, destination_folder):
    logging.info(f'working on local problems for {set_name}, with destination {set_folder}')

    files_to_remove = set()

    for p in set(problems['local_problems']): # using a set so if a problem is listed twice it's ok!
        path = pathlib.Path(p)
        parent = path.parent

        images = find_images(join(source_folder,parent))
        moved_images = False
        if images:
            problem_source = open(join(source_folder,p),'r').read()
            for img in images:
                if str(img.name) in problem_source:
                    # need to copy the image too!

                    logging.info(f'{img} used in {p}, so copying')
                    shutil.copy2(src=img, dst=join(destination_folder,set_folder) ) # arguments are source, destination
                    files_to_remove.add(str(img).replace(source_folder, destination_folder))
                    moved_images = True
                else:
                    # print(f'{img} not used in {p}, so not copying')
                    pass

        # make two temporary paths to work with.
        a = join(destination_folder,p)
        b = join(destination_folder,set_folder,pathlib.Path(p).name)

        # replace old path in .def file with new one.
        problems['def_file_source'] = problems['def_file_source'].replace(p,join(set_folder,pathlib.Path(p).name))



        # if a == b:
        #     print(f'location same before and after {a} {b}')
        #     continue




        logging.info(f'\tcopying problem {a} to {b}')
        try:
            shutil.copy2(src=a, dst=b)

            # add a message to the problem source code documenting the move
            with open(b,'r',encoding='utf-8') as f:
                orig_source = f.read()

            with open(b, 'w', encoding='utf-8') as f:
                top, bottom = orig_source.split('DOCUMENT();',1)


                f.write(top)

                f.write(f"\n\n")
                f.write('#'*40)
                f.write(f"\n# this file automatically moved\n#\tfrom {a.replace(destination_folder,'').strip('/')} \n#\tto {b.replace(destination_folder,'').strip('/')} \n#\ton {today} by silviana amethyst.\n")
                f.write(f'# if this problem uses static images, they should also have been moved from that location to here.\n# if not, look in the source directory for images that didn\'t make it.\n')
                f.write('#'*40)
                f.write('\n\n\n')
                f.write('DOCUMENT();')
                f.write(bottom)

            files_to_remove.add(join(destination_folder,p))

        except shutil.SameFileError as e:
            logging.info(f'skipping {a} since it is already in correct location')

       

    return files_to_remove


def canonicalize_opl_problems(set_name, problems, set_folder, source_folder, destination_folder):
    logging.info(f'working on OPL problems for {set_name}, with destination {set_folder} and source {source_folder}')

    for p in set(problems['problems_in_opl']): # using a set so if a problem is listed twice it's ok!

        q = p.replace('Library',source_folder)

        path = pathlib.Path(q)
        parent = path.parent

        images = find_images(parent)

        moved_images = False
        if images:
            problem_source = open(q,'r').read()
            for img in images:
                if str(img.name) in problem_source:
                    # need to copy the image too!

                    logging.info(f'{img} used in {q}, so copying')
                    shutil.copy2(src=img, dst=join(destination_folder,set_folder) ) # arguments are source, destination
                    moved_images = True
                else:
                    # print(f'{img} not used in {q}, so not copying')
                    pass

        a = join(q)
        b = join(destination_folder,set_folder,pathlib.Path(p).name)


        # replace old path in .def file with new one.
        problems['def_file_source'] = problems['def_file_source'].replace(p,join(set_folder,pathlib.Path(p).name))

        logging.info(f'\tcopying problem {a} to {b}')
        shutil.copy2(src=a, dst=b)


        # add a message to the problem source code documenting the move
        with open(b,'r',encoding='utf-8') as f:
            orig_source = f.read()

        with open(b, 'w', encoding='utf-8') as f:
            top, bottom = orig_source.split('DOCUMENT();',1)

            f.write(top)

            f.write(f"\n\n")
            f.write('#'*40)
            f.write(f"\n# this file automatically moved\n#\tfrom {a.replace(source_folder,'Library')} \n#\tto {b.replace(destination_folder,'').strip('/')} \n#\ton {today} by silviana amethyst.\n")
            f.write(f'# if this problem uses static images, they should also have been moved from that location to here.\n# if not, look in the source directory for images that didn\'t make it.\n')
            f.write('#'*40)
            f.write('\n\n\n')
            f.write('DOCUMENT();')

            f.write(bottom)


    return set() # force return empty set because don't want to remove files from the OPL directory






def canonicalize_missing_problems(set_name, problems, set_folder, source_folder, destination_folder):
    logging.info(f'working on missing OPL problems (where `local` is prepended, but no local copy exists) for {set_name}, with destination {set_folder} and source {source_folder}')
    print(f'\n\n------------\n\n{set_name}\n\n')


    for p in set(problems['missing_problems']): # using a set so if a problem is listed twice it's ok!

        

        try:
            q = p.replace('local/Library',source_folder)


            path = pathlib.Path(q)
            parent = path.parent

            images = find_images(parent)

            moved_images = False
            if images:
                problem_source = open(q,'r').read()
                for img in images:
                    if str(img.name) in problem_source:
                        # need to copy the image too!

                        logging.info(f'{img} used in {q}, so copying')
                        shutil.copy2(src=img, dst=join(destination_folder,set_folder) ) # arguments are source, destination
                        moved_images = True
                    else:
                        # print(f'{img} not used in {q}, so not copying')
                        pass

            a = join(q)
            b = join(destination_folder,set_folder,pathlib.Path(p).name)


            # replace old path in .def file with new one.
            problems['def_file_source'] = problems['def_file_source'].replace(p,join(set_folder,pathlib.Path(p).name))

            logging.info(f'\tcopying problem {a} to {b}')
            shutil.copy2(src=a, dst=b)


            # add a message to the problem source code documenting the move
            with open(b,'r',encoding='utf-8') as f:
                orig_source = f.read()

            with open(b, 'w', encoding='utf-8') as f:
                top, bottom = orig_source.split('DOCUMENT();',1)

                f.write(top)

                f.write(f"\n\n")
                f.write('#'*40)
                f.write(f"\n# this file automatically moved\n#\tfrom {a.replace(source_folder,'Library')} \n#\tto {b.replace(destination_folder,'').strip('/')} \n#\ton {today} by silviana amethyst.\n")
                f.write(f'# if this problem uses static images, they should also have been moved from that location to here.\n# if not, look in the source directory for images that didn\'t make it.\n')
                f.write('#'*40)
                f.write('\n\n\n')
                f.write('DOCUMENT();')

                f.write(bottom)


            print(f'✅ missing problem {p} to {q}')
        except Exception as e:
            print(f'🚫 failed to resolve missing problem due to: {e}')



    return set() # force return empty set because don't want to remove files from the OPL directory







def canonicalize_set(set_name, problems, source_folder, destination_folder):
    """
    canonicalizes one problem set.  definition filename is `set_name`, `problems` is the parsed list of problems.

    `problems` should be a dict-like object containing information about the problems.
    """

    files_to_remove = set()


    logging.info(f'canolicalizing problem locations for {set_name}')

    set_folder = set_name.replace('.def','')

    complete_destination_this_set = join(destination_folder, set_folder)

    if not exists(complete_destination_this_set):
        os.mkdir(complete_destination_this_set)

    logging.info(f'working on {set_name}, with destination {complete_destination_this_set}')

    # this call modifies the .def file (in memory), and adds the addlocal problem to the list of local problems, after adding local.  huzzah.
    canonicalize_addlocal_problems(set_name, problems, set_folder, source_folder, destination_folder)


    # these problems all exist, so can copy images and pg source
    files_to_remove.update(canonicalize_local_problems(set_name, problems, set_folder, source_folder, destination_folder))
    files_to_remove.update(canonicalize_opl_problems(set_name, problems, set_folder, join('webwork-open-problem-library','OpenProblemLibrary'), destination_folder))
    files_to_remove.update(canonicalize_missing_problems(set_name, problems, set_folder, join('webwork-open-problem-library','OpenProblemLibrary'), destination_folder))




    # this next line corrects a spurious addition of the word local to the path for "addlocal" problems, 
    # and this was the easiest fix (though not the best, admittedly.)
    problems['def_file_source'] = problems['def_file_source'].replace('local/','') 

    with open(join(destination_folder,set_name),'w') as f:
        f.write(problems['def_file_source'])

    return files_to_remove
    # done!



def remove_blank_problem(destination_folder):
    dry_run = False
    for parent, dirnames, filenames in os.walk(destination_folder):
        for fn in filenames:
            if fn == 'blankProblem.pg':
                if dry_run:
                    print(f'want to remove {join(parent, fn)}')
                else:
                    logging.info(f'removing {join(parent, fn)}')
                    os.remove(join(parent, fn))

def remove_empty_folders(destination_folder):
    dry_run = False

    num = 0
    for path, _, _ in os.walk(destination_folder, topdown=False):

        if len(os.listdir(path)) == 0:
            if dry_run:
                print(f'want to remove empty directory {path}')
            else:
                logging.info(f'removing empty directory {path}')
                os.rmdir(path)
                num += 1
    return num

def canonicalize_problem_locations(source_folder, destination_folder):
    '''
    a high-level function that gets problem set information and loops over them to canonicalize one at a time
    '''


    logging.info(f'canonicalizing problem locations for {source_folder} with target {destination_folder}')


    # get things ready by copying old folder. 
    copy_folder(source_folder, destination_folder)


    source_problem_set_info = get_folder_information(source_folder)

    files_to_remove = set() # this grows over the following loop, and we'll end by removing the files.

    for set_name, problems in source_problem_set_info.items():
        files_to_remove.update(canonicalize_set(set_name, problems, source_folder, destination_folder))

    
    for p in files_to_remove:
        logging.info(f'removing file {p}')
        os.remove(p)

    remove_blank_problem(destination_folder)

    try_to_remove = True
    while try_to_remove:
        try_to_remove = remove_empty_folders(destination_folder)>0




if __name__ == "__main__":

    logging_setup()


    source_folder = 'templates_20230701_1507'
    destination_folder = f'result'

    canonicalize_problem_locations(destination_folder=destination_folder, source_folder=source_folder)

