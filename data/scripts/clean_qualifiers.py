"""Script to clean the criminal code qualifiers data."""

import sys

from cleaning_helpers import extract_code_number


def process(infile, outfile):
    """Read the raw data from [infile] and write cleaned data to [outfile]."""
    rows = open(infile).read().splitlines()
    print('Dropping the first row: %s' % rows[0])
    rows = rows[1:]
    split_rows = []
    l1 = len('32                       ')
    l2 = l1 + len('PCACCESSORY                     ')
    l3 = l2 + len('ACCESSORY   ')
    for r in rows:
        parts = [r[:l1], r[l1:l2], r[l2:l3], r[l3:]]
        split_rows.append([p.strip() for p in parts])
    print(split_rows[:3])
    split_rows.sort(key=lambda r: extract_code_number(r[0]))
    with open(outfile, 'w') as f:
        for row in split_rows:
            f.write(' '.join(row) + '\n')


def main(infile, outfile):
    """Usually should not need to change this method, but do so as needed."""
    print('Will save processed file to {}'.format(outfile))
    print('Processing...')
    process(infile, outfile)
    print('...success!')


if __name__ == '__main__':
    main(*sys.argv[1:])
