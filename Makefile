
build:
	cake build

auto:
	cake autobuild

exclude  =
exclude +='*.git*'
exclude +='*.coffee'
exclude +='*/README*'
exclude +='*/Cakefile'
exclude +='*/Makefile'

zipfile = ../chromi.zip

zip:
	-rm -v $(zipfile)
	cd .. && zip -r chromi chromi -x $(exclude)
	unzip -l $(zipfile)

