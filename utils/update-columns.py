import sys
import os
import csv
import glob
import shutil
import datetime
import logging
logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

def update_rows(path_input, path_output):
    """
    For each line with only 5 columns, add the contents of the 5th column as a new 6th column
    """
    # Read the file
    logging.debug(f"read path_input=({path_input})")
    with open(path_input, 'rt') as f:
        rows = list(csv.reader(f, delimiter='\t'))
    logging.debug(f"read lines=({len(rows)})")
    lines_updated = 0
    lines_skipped = 0
    for i in range(len(rows)):
        if rows[i][0].startswith('#'):
            lines_skipped += 1
            continue
        assert len(rows[i]) == 5 or len(rows[i]) == 6, "Must be 5 or 6 columns"
        if len(rows[i]) == 5:
            rows[i].append(rows[i][4])
            lines_updated += 1
    logging.debug(f"lines_skipped=({lines_skipped}), lines_updated=({lines_updated})")
    logging.debug(f"write path_output=({path_output})")
    with open(path_output, 'wt', newline='') as f:
        writer = csv.writer(f, delimiter='\t', lineterminator='\n')
        writer.writerows(rows)

def backup_file(path):
    dir_name = os.path.dirname(path)
    file_name = os.path.basename(path)
    date_str = datetime.datetime.now().strftime("%Y-%m-%dT%H-%M-%S")
    backup_file_name = f"bak.{date_str}.{file_name}"
    backup_path = os.path.join(dir_name, backup_file_name)
    logging.debug(f"make backup=({backup_path})")
    shutil.copy(path, backup_path)

def get_cloud_folders():
    base_dir = os.getenv('mld_out_cloud_shared')
    paths = glob.glob(os.path.join(base_dir, '*', 'logs', 'vimh.vi.txt'))
    result = [os.path.dirname(path).replace(base_dir, '').split(os.sep)[1] for path in paths]
    return result

def get_input_output(hostname):
    path_input = os.path.join(os.getenv("mld_out_cloud_shared"), hostname, "logs", "vimh.vi.txt")
    path_output = f"/tmp/vimh-{hostname}-updated.txt"
    return (path_input, path_output)


if __name__ == '__main__':
    #cloud_folders = [ 'Minerva' ]
    cloud_folders = get_cloud_folders()
    for f in cloud_folders:
        path_input, path_output = get_input_output(f)
        backup_file(path_input)
        update_rows(path_input, path_input)

