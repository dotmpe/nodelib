# Id: nodelib/0.0.5-test+20150718-2033 Rules.nodelib.mk

include $(DIR)/Rules.git-versioning.shared.mk

# special rule targets
STRGT += \
   usage \
   update

DEFAULT := usage
empty :=
space := $(empty) $(empty)
usage:
	@echo 'usage:'
	@echo '# npm [info|update|test]'
	@echo '# make [$(subst $(space),|,$(STRGT))]'

install::
	npm install
	make test

STRGT += mocha
mocha: X :=
mocha:
	mocha --check-leaks --compilers coffee:coffee-script/register test/mocha/ $(X)

test:: check mocha

update:
	./bin/cli-version.sh update
	npm update

build:: TODO.list

TODO.list: Makefile bin/ lib/ src/ test/ tools/ ReadMe.rst reader.rst package.yaml Sitefile.yaml
	grep -srI 'TODO\|FIXME\|XXX' $^ | grep -v 'grep..srI..TODO' | grep -v 'TODO.list' > $@

git-pre-commit::
	@git-versioning check


