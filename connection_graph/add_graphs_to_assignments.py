import markdown2canvas as mc
import webwork2canvas as wc
import subgraph_of_related
from bs4 import BeautifulSoup

import os.path as path

class GraphImageAdder(wc.Tool):

	def __init__(self, config_name = 'config.json'):
		super(GraphImageAdder, self).__init__(config_name)


		self.assignments = None
		self.graph_name_map = None
		self.canvas_name_map = None


		self._read_canvas_name_map()
		self._read_graph_name_map()


	def _read_canvas_name_map(self):
		map_name = self.config['name_map']


		import json
		with open(map_name,'r') as f:
			self.canvas_name_map = json.load(f)


	def _read_graph_name_map(self):
		map_name = self.config['graph_name_map']


		import json
		with open(map_name,'r') as f:
			self.graph_name_map = json.load(f)


	# this is duplicated from webwork2canvas.  factor it out, i hate code duplication
	def _get_links(self):
		source_name = 'homework_sets.html'
		soup = BeautifulSoup(open(source_name,'r').read(), 'html.parser')

		table = soup.find("table")
		rows = table.find_all('tr')

		counter = 0

		entries = {}
		for r in rows:

			
			cells = r.find_all('td')

			
			if len(cells)>0:


				# this seems to drift per-semester.  if it breaks, use a jupyter notebook to figure it out.
				q = cells[0]


				# timed "tests" have a clock at their start which causes me to have to do this 🔩:
				hw_name = q.find(text=True)
				if 'with time limit' in hw_name:
					hw_name = q.find_all('span')[1].find(text=True)

				link = q.find_all('a', href=True)[0]['href'].split('?')[0]

				entries[hw_name] = {'link':link,'ww_name':hw_name,'name':hw_name}
				counter += 1
		

		self.assignments = entries

	def _copy_files(self, destdir='_generated_graphs'):
		import os
		if not os.path.exists(destdir):
			os.mkdir(destdir)

		import shutil

		shutil.copy2('legend.uml',path.join(destdir,'legend.uml'))
		shutil.copy2('style.uml',path.join(destdir,'style.uml'))


	def _generate_images(self, dry_run=False):
		graph_names = {}
		# first, generate graphs to subdirectory
		for wwname in self.assignments.keys():
			# print(wwname)
			# print(self.graph_name_map[wwname] if wwname in self.graph_name_map else f'not in graph: {wwname}')
			if self.graph_name_map[wwname] == "":
				print(f'ℹ️ no node named {wwname} in connection graph, so will not generated the subgraph or add an image to canvas')
			else:
				image_name = subgraph_of_related.generate_subgraph(self.graph_name_map[wwname],'_generated_graphs', dry_run)

				graph_names[wwname] = image_name

		return graph_names


	def _make_html_for_image(self, image):

		im_id = image.canvas_obj.id
		course_id = self.config['course_id']
		alt = f'A graph of connections between assignments, with a pin emoji and a note denoting "you are here" at the current assignment.'

		return f'<p><img id="{im_id}" src="/courses/{course_id}/files/{im_id}/preview" alt="{alt}" /></p>'



	def _add_graphs_to_assignment(self, graph_names, dry_run=False):
		"""
		graph_names is a dict of strings of spacey webwork assignment names to filenames for the generated images.
		"""

		course = self._get_canvas_course()


		for wwname in graph_names:

			canvas_name = self.canvas_name_map[wwname]['name']

			if not dry_run:
				print(f'adding graph to assignment {canvas_name}')
				image = mc.Image(filename=graph_names[wwname])
				assignment = mc.find_assignment_in_course(canvas_name, course)

				image.publish(course, 'assignment_graphs', overwrite=True)
				assignment.edit(assignment={'description':self._make_html_for_image(image)})
			else:
				print(f'dry run.  would publish {graph_names[wwname]} to {canvas_name} here.')



	def _get_canvas_course(self):

		# my sandbox course i just made (via the "help" menu in Canvas) uses the actual uwec link
		canvas_url = self.config['canvas_url']  # for actual teaching courses at uwec
		course_id = self.config['course_id'] 

		canvas = mc.make_canvas_api_obj(url=canvas_url)
		return canvas.get_course(course_id) 



	def main(self):


		self._get_links()

		self._copy_files(destdir='_generated_graphs')

		graph_names = self._generate_images(dry_run = False)

		self._add_graphs_to_assignment(graph_names,dry_run = True)




if __name__ == "__main__":
	tool = GraphImageAdder()
	tool.main()