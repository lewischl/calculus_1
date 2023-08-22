from os import listdir, rename
from os.path import isfile, join, exists
import os

def get_set_names(folder):
    
    onlyfiles = [f for f in listdir(folder) if isfile(join(folder, f))]

    set_names = [f for f in onlyfiles if f.endswith('.def')]
    set_names.sort()
    return set_names





def canonicalize_def_names(folder):
    set_names = get_set_names(folder)

    for s in set_names:
    	new_s = s.replace('-','_').replace('_nohint','_-_no_hints')
    	print(s,new_s)
    	rename(join(folder,s),join(folder,new_s))



folder = 'templates_20230608_before_moving_group_sources'
canonicalize_def_names(folder)