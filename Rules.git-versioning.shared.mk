# Id: git-versioning/0.0.16-dev-master+20150504-0242 Rules.git-versioning.shared.mk
# special rule targets
STRGT += \
   version \
   check \
   path release tag \
   publish

version:
	@git-versioning version

check:
	@$(echo) -n "Checking for $(APP_ID) version "
	@git-versioning check

patch:
	@git-versioning increment

release: maj := 
release:
	@git-versioning increment true $(maj)

tag:
	@git tag $(APP_ID)/$$(git-versioning version)
	@echo "New tag: $(APP_ID)/$$(git-versioning version)"
	@git-versioning increment
	@./tools/prep-version.sh


# XXX: GIT publish
publish: DRY := yes
publish: check
	@[ -z "$(VERSION)" ] && exit 1 || echo Publishing $(git-versioning version)
	git push
	@if [ $(DRY) = 'no' ]; \
	then \
		git tag v$(VERSION)
		git push fury master; \
		npm publish --tag $(VERSION); \
		npm publish; \
	else \
		echo "*DRY* $(VERSION)"; \
	fi
