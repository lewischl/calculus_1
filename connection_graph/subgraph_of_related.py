import sys # for argument parsing

import networkx as nx
import matplotlib.pyplot as plt
import PIL

import os.path as path
import os


def read_graph_with_preprocessing():


	with open('homework_graph.uml','r') as f:
		preproc_txt = f.read();

	preproc_txt = preproc_txt.replace('"','')

	with open('homework_graph_preprocessed.uml','w') as f:
		f.write(preproc_txt)


	G = nx.read_edgelist('homework_graph_preprocessed.uml',
	    create_using=nx.DiGraph,
	    nodetype=str, delimiter=" --> ")

	return G


def ensure_center_in_graph(center, G):
	for e in G.edges():
		if e[0] == center or e[1] == center:
			return True

	raise RuntimeError(f'center {center} not found in graph!')







def generate_subgraph(center, destdir='_generated_graphs', dry_run = False, legend = False):

	print(f'generating subgraph for {center}')

	if not os.path.exists(destdir):
		os.mkdir(destdir)



	G = read_graph_with_preprocessing()



	ensure_center_in_graph(center, G)



	

	
	def decide_subgraph(d):
		keep_me = []
		node_type = {center: 'center'}
		for n in G.nodes():
			try:
				dist_this = nx.shortest_path_length(G,n,center)

				if n not in node_type:
					node_type[n] = 'ancestor'
			except:
				try:
					dist_this = nx.shortest_path_length(G,center, n)

					if n not in node_type:
						node_type[n] = 'descendant'

				except:
					continue

			if dist_this <= d:
				keep_me.append(n)

		return keep_me, node_type


	def trim_long_paths(subgraph, keep_me, node_type, threshold=3):

		# print('\n\ntrimming long paths\n')


		no_really_keep_me = [center]

		# print(keep_me)
		for n in keep_me:
			

			if node_type[n]=='ancestor':
				paths_to_center = nx.all_simple_paths(subgraph, n, center)
			elif node_type[n]=='descendant':
				paths_to_center = nx.all_simple_paths(subgraph, center, n)
			elif n == center:
				continue


			# print(f'{center} {n}')
			try:
				longest_path_length = len(max(paths_to_center, key=lambda x: len(x)))-1
				# print(n, center, longest_path_length)
				if longest_path_length<=threshold:
					no_really_keep_me.append(n)

			except ValueError as e:
				pass # can't get to it, remove it.


		assert center in no_really_keep_me
		return no_really_keep_me


	def trim_high_degree_nodes(subgraph, keep_me, node_type, threshold=3):
		# print('\n\ntrimming high-degree nodes\n')

		no_really_keep_me = set(keep_me) # subtractive synthesis for this

		for n in keep_me:
			d = nx.degree(subgraph, n)
			# print(n, d)

			if d > threshold and node_type[n] == 'descendant':
				# print(f'trimming successors from {n}')
				for s in subgraph.successors(n):
					# print(f'removing {s}')
					if s in no_really_keep_me:
						no_really_keep_me.remove(s)	

			if d > threshold and node_type[n] == 'ancestor':
				# print(f'trimming predecessors from {n}')
				for s in subgraph.predecessors(n):
					# print(f'removing {s}')
					if s in no_really_keep_me:
						no_really_keep_me.remove(s)

		assert center in no_really_keep_me
		return no_really_keep_me


	keep_me, node_type = decide_subgraph(2)

	subgraph = nx.induced_subgraph(G,keep_me)



	big_graph_threshold = 12

	if len(keep_me)>big_graph_threshold:
		keep_me = trim_high_degree_nodes(subgraph, keep_me, node_type)
		subgraph = nx.induced_subgraph(G, keep_me)


	if len(keep_me)>big_graph_threshold:
		keep_me = trim_long_paths(subgraph, keep_me, node_type)
		subgraph = nx.induced_subgraph(G, keep_me)



	center_nicename = center.lower().replace('"','').replace(' ','_')
	uml_filename = path.join(destdir, f'{center_nicename}.uml')
	image_filename = path.join(destdir, f'{center_nicename}.png')


	if dry_run:
		return image_filename



	encountered = set()
	type_to_plantuml_tag_map = {'center': "<< Current >>", 'ancestor': "<< EarlierContent >>", 'descendant': "<< LaterContent >>"}


	with open(uml_filename,'w') as file: 
		file.write('@startuml\n')
		file.write('!include style.uml\n')

		file.write('partition "Connection graph" \n\n')


		for e in subgraph.edges():

			source = e[0]
			target = e[1]

			source_node_type = ""
			target_node_type = ""

			if source not in encountered:
				encountered.add(source)
				source_node_type = type_to_plantuml_tag_map[node_type[source]]

			if target not in encountered:
				encountered.add(target)
				target_node_type = type_to_plantuml_tag_map[node_type[target]]

			if target == center:
				target = '📍 ' + center
			if source == center:
				source = '📍 ' + center
			file.write(f'"{source}" {source_node_type} --> "{target}" {target_node_type}\n')






		file.write('}\n')

		if legend:
			file.write('!include legend.uml\n')

		file.write('@enduml\n')




	import subprocess
	subprocess.run(["plantuml", "-tpng", uml_filename]) 

	return image_filename



if __name__ == "__main__":

	if len(sys.argv) == 1:
		raise RuntimeError('this script must be passed a name of a node')
	center = sys.argv[1]

	generate_subgraph(center, destdir='_generated_graphs')





	# https://networkx.org/documentation/stable/auto_examples/drawing/plot_custom_node_icons.html

	# pos = nx.planar_layout(G)
# pos = nx.nx_agraph.graphviz_layout(subgraph)
# fig, ax = plt.subplots()

# nx.draw_networkx(
#     subgraph,
#     pos=pos,
#     ax=ax,
#     arrows=True,
#     arrowstyle="->",
#     min_source_margin=15,
#     min_target_margin=15,
# )

# fig.savefig('the_graph.pdf')
