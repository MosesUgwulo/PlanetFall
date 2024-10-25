import json

def update_readme():
    with open('trello_data.json', 'r') as file:
        cards = json.load(file)

    # Build the README content
    readme_content = "# Trello Board Updates\n\n"
    for card in cards:
        readme_content += f"- {card['name']} ([Link]({card['url']}))\n"

    with open("README.md", "w") as readme:
        readme.write(readme_content)

if __name__ == "__main__":
    update_readme()
