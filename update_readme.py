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
        lists[list_name].append(card)

    # Build the README content with tables
    readme_content = "# Trello Board Updates\n\n"
    for list_name, cards in lists.items():
        readme_content += f"## {list_name}\n\n"
        
        # Create table header
        readme_content += "| Card Name | Link | Image |\n"
        readme_content += "|-----------|------|-------|\n"
        
        # Populate table rows with card details
        for card in cards:
            card_name = f"**{card['name']}**"
            card_link = f"[Link]({card['url']})"
            card_image = f"![Image]({card['image_url']})" if 'image_url' in card and card['image_url'] else "No image"
            
            # Add row to the table
            readme_content += f"| {card_name} | {card_link} | {card_image} |\n"
        
        # Add a blank line after each table for spacing
        readme_content += "\n"

    with open("README.md", "w") as readme:
        readme.write(readme_content)

if __name__ == "__main__":
    update_readme()
