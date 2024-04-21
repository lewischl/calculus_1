import markdown2canvas as mc
import json
import pandas as pd







class StandardsMaker(mc.tool.Tool):
    """docstring for StandardsMaker"""
    def __init__(self, config_name = 'config.json'):
        super(StandardsMaker, self).__init__(config_name)

        self.links = None
        self.assignments = None
        self.standards = None
        self.all_canvas_assignments = None

        self._read_standards()
        self._canvas_setup()


    def _read_standards(self):
        self._require_have_config()


        import json
        with open("list_of_standards.json",'r') as f:
            self.standards = pd.DataFrame(json.load(f))

        print(self.standards)


    def _require_have_assignments(self):
        if self.assignments is None:
            raise mc.SetupError("we don't have the assignments yet.  you have to populate self.assignments first")

    def _require_file_exists(self, filename):
        if not path.exists(filename):
            raise mc.DoesntExist(f'file `{filename}` does not exist, but it should.  please ensure the file is saved with this name.')


    def _get_assignments_from_canvas(self):
        assert self.course is not None

        assignments = self.course.get_assignments()

        self.all_canvas_assignments = []
        for a in assignments:
            self.all_canvas_assignments.append(a)

        print(dir(a))

    def _get_list_of_related_assignments(self):
        assert self.all_canvas_assignments is not None

        self.standards['related_assignments'] = self.standards.apply(lambda row: [n for n in self.all_canvas_assignments if (row['name'] in n.name and not n.name.startswith('⛳️'))] ,axis=1) # this is incorrect if there are more than 10 standards in a category!!!!  or if one is a substring of another.
        print(self.standards['related_assignments'])






    def _save_assignments_to_disk(self):
        # turns the hwname, link, etc, into a homework assingment compatible with my markdown2canvas package, so that I can thusly publish it.
        
        def make_assignment(assignment_data):
            # takes a row of data from the standards data frame and turns into a markdown2canvas assignment.
            # adds a column into the data frame of the folder that got created for the standard.

            import os
            
            import json
            from os.path import join
            dirname = join('automatically_generated_assignments',assignment_data['name']+".assignment")

            if not os.path.isdir(dirname):
                os.makedirs(dirname);

            meta_data = {
                          "name":f"⛳️ {assignment_data['name']}",
                          "type": "assignment",
                          "points_possible": assignment_data.value * assignment_data.num_demonstrations,
                          "style":"_styles/assignments",
                          "assignment_group_name":"⛳️ Learning standards",
                          "modules": ["⛳️ Learning standards"]
                        }
            

            with open(join(dirname,'meta.json'),'w') as f:
                json.dump(meta_data, f, indent = 4)


            def make_due_date(canvas_obj):

                due_at = canvas_obj.due_at_date.astimezone()
                return f"{due_at.month}/{due_at.day}"


            supporting_assignments = '\n'.join([f'* <a href="assignment:{n.name}">{n.name}</a>, due {make_due_date(n)}' for n in assignment_data.related_assignments]) + '\n\n'


            description = (
                f"## ⛳️ Learning standard {assignment_data['name']}\n\n"
                f"### Description\n\n<div class=\"callout minimal info shadowed\" role=\"note\" markdown=\"1\">\n{assignment_data.description}\n</div>\n\n"
                f"### Value\n\nThis standard is valued at {assignment_data.value} points per demonstration of mastery.\n\nYour target is to demonstrate mastery at this learning standard {assignment_data.num_demonstrations} times.\n\nThe total point value of this standard is therefore {assignment_data.value * assignment_data.num_demonstrations} points.\n\n"
                f"### Supporting assignments:\n\n{supporting_assignments}\n\n"
                f"### Suggested book reading\n\n{assignment_data.book_reading}\n\n"
                f"### Suggested book problems\n\n{assignment_data.book_problems}\n\n"
                )   





            with open(join(dirname,'source.md'),'w') as f:
                f.write(description)

            return dirname


        standards = self.standards # unpack

        standards['dirname'] = standards.apply(make_assignment,axis=1) # make assignment, and save the dirname




    def _publish_assignments_to_canvas(self):

        standards = self.standards


        def pub_ass(row):
            
            mc_ass = mc.Assignment(row['dirname'])

            print("publishing {}".format(row['name']))

            if not self.config['dry_run']:
                mc_ass.publish(self.course,overwrite=True,create_assignment_group_if_necessary=True)
            else:
                print(f'\tdry run, not actually publishing to canvas.  now working on {row["name"]}')


        standards.apply(pub_ass,axis=1)





    def _write_report_to_disk(self):

        self.standards.to_excel('inspectme.xlsx')




    def main(self):

        self._get_assignments_from_canvas()
        self._get_list_of_related_assignments()

        

        self._save_assignments_to_disk() # saves assignments into format compatible with my markdown2canvas packaging and publishing library

        self._write_report_to_disk()

        self._publish_assignments_to_canvas()






if __name__ == "__main__":
    StandardsMaker().main()



