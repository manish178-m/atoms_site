PAGES = $(wildcard pages/*.md)

.PHONY: clean view all

all:
	tools/pre_process_dl.sh people
	tools/pre_process_dl.sh former
	make en/index.html

en/index.html: proc/people.md proc/former.md proc/publications.md $(PAGES)
	doxygen
	tools/post_process.sh

proc/people.md: pages/people.md
	tools/pre_process.sh people

proc/former.md: pages/former.md
	tools/pre_process.sh former

proc/publications.md: pages/publications.md pages/publications.bib
	tools/pre_process.sh publications

clean:
	rm -rf en/*
	rm -rf proc/*
	ls images/K* | grep 'K[0-9]\{7\}[A-Z][0-9].jpg' | xargs rm -f

view:
	touch pages/index.md
	make all
	firefox en/index.html

review:
	touch pages/index.md
	make en/index.html
	firefox en/index.html

