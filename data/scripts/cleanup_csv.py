"""Cleans CSVs sent to us by DOJ."""

import csv
import sys


def process(infile, outfile, columns):
    """Convert and clean according to a few rules."""
    to_drop = [i for i, item in enumerate(columns) if item == 'DROP']
    if to_drop:
        print('Dropping columns: {}'.format(to_drop))
        to_drop.reverse()  # So we can iterate through and drop
    for idx in to_drop:
        columns.pop(idx)
    to_write = [columns]

    with open(infile) as f:
        reader = csv.reader(f)
        for row in reader:
            for idx in to_drop:
                row.pop(idx)
            row = [elt.strip() for elt in row]
            to_write.append(row)

    with open(outfile, 'w') as f:
        writer = csv.writer(f)
        for row in to_write:
            writer.writerow(row)


def main(infile, outfile, columns):
    """Usually should not need to change this method, but do so as needed."""
    columns = columns.split(',')
    print('Will save processed file to {}'.format(outfile))
    print('Processing...')
    process(infile, outfile, columns)
    print('...success!')


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(('Usage: %s [input_filename] [output_filename] '
               '[column1,DROP,column2,...,columnN]' % sys.argv[0]))
        sys.exit(1)
    main(*sys.argv[1:])
