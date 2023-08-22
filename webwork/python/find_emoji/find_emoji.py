import emoji
import pathlib

templates = pathlib.Path("templates")

all_emoji = []

for f in templates.rglob("*.pg"):
	with open(f,'r') as file:

		source = file.read()

		found_emoji = emoji.emoji_list(source)

		all_emoji.extend([a['emoji'] for a in found_emoji])

unique_emoji = '\n'.join(list(set(all_emoji)))
print(unique_emoji)


with open('unique_emoji.tex',encoding='utf8',mode='w') as out:
	out.write(unique_emoji)




