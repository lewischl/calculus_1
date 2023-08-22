This Python code merges problems from two Webwork courses.

---

## Assumptions

* In both courses, you have the most recent versions of the .def files for all homeworks you wish to preserve
* Edit `merge_map.json` to express which sets are merged into where
* Adjust file paths in `merge.py` to be the correct direction

---

## Products

* `merge_results.log` -- gory detail
* `source_problem_set_info.json` -- a bunch of information about the source problem sets
* `destination_problem_set_info.json` -- a bunch of information about the destination problem sets
* `merged_local_problems.txt` -- a list of problems that were copied into the results folder.  
* `merge_results/` -- the resulting file.  Derived from a copy of the destination folder.  `.def` files are modified to contain problems from both source and destination, and the `.pg` files from source have been copied in, too.

---

## After merging

After merging, you will need to delete old homeworks, and import from the uploaded .def files in the `merge_results`.  You will also need to upload the .pg files, probably by zipping, uploading, and unpacking.  Good luck.

---

## Weaknesses / known flaws:

* If a problem copied from source into destination had an image or other auxiliary files, they were definitely not copied.  That was just out of reach for me, sorry.

---

## Disclaimer

* This code comes with absolutely no warranty or claim of fitness for any purpose whatsoever.  Use at your own risk.

