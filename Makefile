
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

zip:
	[ -f ../chromi.zip ] && rm -v ../chromi.zip && true
	cd .. && zip -r chromi chromi -x $(exclude)
	unzip -l ../chromi.zip

