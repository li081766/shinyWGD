import os
import re
import sys

def rename_species(input_string):
    pattern = r'(\w+)_(\w+)'

    def rename(match):
        return match.group(1) + match.group(2).capitalize()

    updated_string = re.sub(pattern, rename, input_string, flags=re.MULTILINE)
    return updated_string

def main(input_file, ale_folder, wgdInfo_file):
    with open(input_file, "r") as file:
        input_string = file.read().strip()

    updated_string = rename_species(input_string)

    with open(input_file.replace(".nwk", "") + ".updated.nwk", "w") as output_file:
        output_file.write(updated_string)

    with open(wgdInfo_file, "r") as file:
        input_wgd = file.read().strip()

    updated_wgd = rename_species(input_wgd)
    
    with open(wgdInfo_file.replace(".txt", "") + ".updated.txt", "w") as outfile:
        outfile.write(updated_wgd)
    
    output_folder_name = os.path.basename(ale_folder) + ".updated"
    output_folder = os.path.join(os.path.dirname(ale_folder), output_folder_name)
    os.makedirs(output_folder, exist_ok=True)

    species_dict = {}
    pattern = r'(\w+)_(\w+)'
    for match in re.finditer(pattern, input_string):
        old_name = match.group(0)
        new_name = match.group(1) + match.group(2).capitalize()
        species_dict[old_name] = new_name

    for file_name in os.listdir(ale_folder):
        file_path = os.path.join(ale_folder, file_name)
        with open(file_path, "r") as file:
            content = file.read()

        for old_name, new_name in species_dict.items():
            content = content.replace(old_name, new_name)

        output_file_path = os.path.join(output_folder, file_name)
        with open(output_file_path, "w") as file:
            file.write(content)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <input_nwk> <ale_folder> <wgdInfo.txt>")
        sys.exit(1)

    input_file = sys.argv[1]
    ale_folder = sys.argv[2]
    wgd_file = sys.argv[3]

    main(input_file, ale_folder, wgd_file)

