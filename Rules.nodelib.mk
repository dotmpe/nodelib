# Id: nodelib/0.0.4-dev+20150422 Rules.nodelib.mk

include $(DIR)/Rules.git-versioning.shared.mk

# special rule targets
STRGT += \
   usage \
   install \
   test \
   update \
   build

DEFAULT := usage
empty :=
space := $(empty) $(empty)
usage:
	@echo 'usage:'
	@echo '# npm [info|update|test]'
	@echo '# make [$(subst $(space),|,$(STRGTS))]'

install::
	npm install
	make test

test: check

update:
	./bin/cli-version.sh update
	npm update

build:: TODO.list

TODO.list: Makefile lib ReadMe.rst reader.rst package.yaml Sitefile.yaml
	grep -srI 'TODO\|FIXME\|XXX' $^ | grep -v 'grep..srI..TODO' | grep -v 'TODO.list' > $@


