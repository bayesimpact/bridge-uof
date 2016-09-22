# This Makefile is for data processing.
# See the README in data/ but in general, any raw data that
# needs processing should have a make rule here taking the
# data file from data/raw/ and creating the necessary outputs.

all: codes app/models/constants/department_by_ori.rb app/models/constants/contracting_oris.rb app/assets/javascripts/police_agency_oris.js app/assets/javascripts/crimes.js app/assets/javascripts/crime_qualifiers.js

clean:
	rm -f data/codes_agency.csv data/codes_city.csv data/codes_county.csv data/codes_criminal.csv data/codes_crime_qualifiers.csv
	rm -f app/models/constants/department_by_ori.rb app/models/constants/contracting_oris.rb app/assets/javascripts/police_agency_oris.js app/assets/javascripts/crimes.js

codes: data/codes_agency.csv data/codes_city.csv data/codes_county.csv data/codes_criminal.csv data/codes_crime_qualifiers.csv

data/codes_agency.csv:
	mkdir -p "$(dir $@)"
	python data/scripts/cleanup_csv.py data/raw/chsagy.csv data/codes_agency.csv "code,agency_name"

data/codes_city.csv:
	mkdir -p "$(dir $@)"
	python data/scripts/cleanup_csv.py data/raw/vccit_city.csv data/codes_city.csv "DROP,city_name,code"

data/codes_county.csv:
	mkdir -p "$(dir $@)"
	python data/scripts/cleanup_csv.py data/raw/vcco_county.csv data/codes_county.csv "DROP,county_name,code"

data/codes_criminal.csv:
	mkdir -p "$(dir $@)"
	python data/scripts/clean_criminal_codes.py data/raw/chsoffls.csv data/codes_criminal.csv

app/assets/javascripts/crimes.js: data/codes_criminal.csv
	python data/scripts/generate_js_from_csv.py data/codes_criminal.csv app/assets/javascripts/crimes.js CRIMES

data/codes_crime_qualifiers.csv:
	mkdir -p "$(dir $@)"
	python data/scripts/clean_qualifiers.py data/raw/chsqua.tbl data/codes_crime_qualifiers.csv

app/assets/javascripts/crime_qualifiers.js: data/codes_crime_qualifiers.csv
	python data/scripts/generate_js_from_csv.py data/codes_crime_qualifiers.csv app/assets/javascripts/crime_qualifiers.js CRIME_QUALIFIERS

app/models/constants/department_by_ori.rb: data/ori.csv
	python data/scripts/generate_ori_rb.py data/ori.csv app/models/constants/department_by_ori.rb

app/models/constants/contracting_oris.rb: data/ori.csv
	python data/scripts/generate_ori_contracts_rb.py data/ori.csv app/models/constants/contracting_oris.rb

app/assets/javascripts/police_agency_oris.js: data/ori.csv
	python data/scripts/generate_ori_js.py data/ori.csv app/assets/javascripts/police_agency_oris.js
