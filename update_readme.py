import json

def update_readme():
    with open('trello_data.json', 'r') as file:
        data = json.load(file)

    # Start building the README content with only the list names as headers
    readme_content = "# Trello Board\n\n"
    
    # Create table header with list names
    list_names = list(data.keys())
    readme_content += "| " + " | ".join(list_names) + " |\n"
    readme_content += "| " + " | ".join(["---"] * len(list_names)) + " |\n"

    # Find the maximum number of cards in any list to set row length
    max_cards = max(len(cards) for cards in data.values())
    
    # Add cards under each list name
    for i in range(max_cards):
        row = []
        for list_name in list_names:
            row.append(data[list_name][i]['name'] if i < len(data[list_name]) else "")
        readme_content += "| " + " | ".join(row) + " |\n"

    with open("README.md", "w") as readme:
        readme.write(readme_content)

if __name__ == "__main__":
    update_readme()
