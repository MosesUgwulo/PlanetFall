import json

def update_readme():
    with open('trello_data.json', 'r') as file:
        data = json.load(file)

    # Group cards by list name
    lists = {}
    for card in data:
        list_name = card.get('list_name', 'Uncategorized')
        if list_name not in lists:
            lists[list_name] = []
        lists[list_name].append(card['name'])

    # Get all list names and the maximum number of cards in any list to structure the table
    list_names = list(lists.keys())
    max_cards = max(len(cards) for cards in lists.values())

    # Build the README content with a single table
    readme_content = "# Trello Board Updates\n\n"

    # Create the table header with list names
    readme_content += "| " + " | ".join(list_names) + " |\n"
    readme_content += "| " + " | ".join(["---"] * len(list_names)) + " |\n"

    # Add rows of card names under each list
    for i in range(max_cards):
        row = []
        for list_name in list_names:
            # Add card name if available, else leave cell empty
            row.append(lists[list_name][i] if i < len(lists[list_name]) else "")
        readme_content += "| " + " | ".join(row) + " |\n"

    with open("README.md", "w") as readme:
        readme.write(readme_content)

if __name__ == "__main__":
    update_readme()
