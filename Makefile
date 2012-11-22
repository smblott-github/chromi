
build:
	cake build

auto:
	cake autobuild

exclude  =
exclude +='*/.git*'
exclude +='*/README*'
exclude +='*/Cakefile'
exclude +='*/Makefile'
exclude +='*.coffee'

zipfile = ../chromi.zip

zip:
	$(MAKE) build
	-rm -v $(zipfile)
	cd .. && zip -r chromi chromi -x $(exclude)
	unzip -l $(zipfile)

