#!/bin/python3

# a script for publishing content that's ready to go!
# this script should be executed from root level in this repo.

dry_run = False

import markdown2canvas as mc

with open('_tools/content_ready','r') as f:
	ready_files = f.read().split('\n')

# strip comments:
ready_files = [f.split('#')[0] for f in ready_files]
ready_files = [f.split('%')[0] for f in ready_files]

# omit empty lines
ready_files = [f'{f}' for f in ready_files if f]

print(ready_files)


from course_info import *

course_id = real_course_id

canvas = mc.make_canvas_api_obj(url=canvas_url)
course = canvas.get_course(course_id) 

print(f'publishing to {course.name}')

def make_mc_obj(f):
	if f.endswith('page'):
		return mc.Page(f), 'page'
	if f.endswith('assignment'):
		return mc.Assignment(f), 'assignment'
	if f.endswith('link'):
		return mc.Link(f), 'link'
	if f.endswith('file'):
		return mc.File(f), 'file'


for f in ready_files:
	print(f)
	obj, typeid = make_mc_obj(f)

	if not dry_run:
		if typeid=='assignment':
			obj.publish(course, overwrite=True, create_modules_if_necessary=True, create_assignment_group_if_necessary=True)
		else:
			obj.publish(course, overwrite=True)
	else:
		print(f'[dry run] publishing {obj}')
