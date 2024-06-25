import os


def remove_last_pipe_from_line(line):
    if line.endswith('|\n'):
        return line[:-2] + "\n"  # Remove the last character if it is '|'
    return line


def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    with open(file_path, 'w', encoding='utf-8') as file:
        for line in lines:
            file.write(remove_last_pipe_from_line(line))


def process_directory(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            process_file(file_path)


# Define the directory containing the files
directory = '/Users/dsherstobitov/Downloads/TPCH-10'

# Process all files in the directory
process_directory(directory)
