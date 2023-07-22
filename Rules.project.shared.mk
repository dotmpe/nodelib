	
SELF = ./Rules.project.shared.mk

SHELL := $(shell which bash)
export BASH_ENV := .meta/cache/bash-env.sh
TRGT += $(BASH_ENV)

$(BASH_ENV): BASH_ENV=
$(BASH_ENV): $(SELF)
	mkdir -vp "${@D}"
	echo -e "shopt -s expand_aliases &&\n"\
		" . \"\$${U_C}/script/stdlog-uc.lib.sh\" &&\n"\
		" . \"\$${US_BIN:=\$$HOME/bin}/tools/sh/parts/als-git.sh\"" >| "$@"

TRGT+=.meta/stat/index/$(APP_ID)-branches.list
.meta/stat/index/$(APP_ID)-branches.list:
	mkdir -vp "${@D}"
	vc.sh branches l origin >| "$@"

sync: build
	git-fetch-v --all && git-pull-every

pub: sync
	git-push-every
