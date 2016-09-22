"""Script to clean the criminal codes data."""

import sys

from cleaning_helpers import extract_code_number

import pandas as pd


def process(infile, outfile):
    """Read the raw data from [infile] and write cleaned data to [outfile]."""
    df = pd.read_csv(infile, header=None)
    print('Read %d rows x %d cols' % df.shape)
    df.head()

    # Name columns and drop unnecessary data
    df.columns = [
        'unknown_0', 'unknown_1', 'unknown_2', 'code', 'book', 'description',
        'unknown_6', 'severity', 'subsection_code', 'degree', 'unknown_10',
        'date_enacted', 'date_removed', 'unknown_13']
    unknown_cols = [col for col in df.columns if col.startswith('unknown')]
    print('Dropping %d unknown cols' % len(unknown_cols))
    df = df.drop(unknown_cols, axis=1)
    print('Dropping %d rows for inactive criminal codes' % sum(
        df['date_removed'] != 99999999))
    df = df[df['date_removed'] == 99999999].drop(
        ['date_enacted', 'date_removed'], axis=1)

    # Create a (hopefully) unique key field
    keys = []
    severities = {
        'M': '(MISDEMEANOR)',
        'F': '(FELONY)'
    }
    for i, row in df.iterrows():
        parts = [
            row['code'],
            row['book'],
            row['description'],
            severities.get(row['severity'], ''),
            row['subsection_code']
        ]
        keys.append(' '.join(str(p) for p in parts if (pd.notnull(p) and p)))
    df['full_key'] = keys

    # Sort keys for smart autocompletion. Default string sorting does
    # a bad job when numbers are involved, and we want all PC codes
    # ("Penal Code", the main California codebook) to appear first.
    df['code_numerical'] = [extract_code_number(c) for c in df['code']]
    df.sort_values(by=['book', 'code_numerical', 'full_key'], inplace=True)
    df = pd.concat([df[df['book'] == 'PC'], df[df['book'] != 'PC']])

    print('Duplicates (should be 0): %d' % (
        len(df) - len(set(df['full_key']))))
    print('Writing %d criminal codes' % len(df['full_key']))
    with open(outfile, 'w') as f:
        f.write('\n'.join(df['full_key']) + '\n')


def main(infile, outfile):
    """Usually should not need to change this method, but do so as needed."""
    print('Will save processed file to {}'.format(outfile))
    print('Processing...')
    process(infile, outfile)
    print('...success!')


if __name__ == '__main__':
    main(*sys.argv[1:])
