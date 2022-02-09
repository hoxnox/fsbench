DIR=fio-test

sources = $(wildcard fio/*.fio)

all: $(sources:.fio=.json)

%.json: %.fio
	fio \
	 --directory=$(DIR) \
	 --output-format=json \
	 --output=$(notdir $@) \
	 $<
