import json

def update_readme():
    with open('trello_data.json', 'r') as file:
        data = json.load(file)

    readme_content = "# Trello Board\n\n"
    
    list_names = list(data.keys())
    readme_content += "| " + " | ".join(list_names) + " |\n"
    readme_content += "| " + " | ".join(["---"] * len(list_names)) + " |\n"

    max_cards = max(len(cards) for cards in data.values())
    
    for i in range(max_cards):
        row = []
        for list_name in list_names:
            if i < len(data[list_name]):
                card = data[list_name][i]
                if 'idAttachmentCover' in card and card['idAttachmentCover']:
                    # If card has a cover image, create image markdown
                    row.append(f"![{card['name']}](https://trello.com/1/cards/{card['id']}/attachments/{card['idAttachmentCover']}/download)")
                else:
                    row.append(card['name'])
            else:
                row.append("")
        readme_content += "| " + " | ".join(row) + " |\n"

    with open("README.md", "w") as readme:
        readme.write(readme_content)

if __name__ == "__main__":
    update_readme()
