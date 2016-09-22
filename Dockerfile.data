FROM tailordev/pandas:0.17.1

RUN mkdir -p /code/data
WORKDIR /code
COPY data/raw data/raw
COPY data/scripts data/scripts
COPY app app
COPY Makefile .

RUN /usr/bin/make clean
RUN /usr/local/bin/pip install xlrd

CMD ["make", "all"]
