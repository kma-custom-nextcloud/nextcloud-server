all: clean dev-setup build-js-production

# Dev env management
dev-setup: clean npm-init

image: build-image push-image

build-image:
	docker build -t ghcr.io/kma-custom-nextcloud/nextcloud-server:22 .

push-image:
	docker push ghcr.io/kma-custom-nextcloud/nextcloud-server:22

npm-init:
	npm ci

npm-update:
	npm update

# Building
build-js:
	npm run dev

build-js-production:
	npm run build

watch-js:
	npm run watch

# Linting
lint-fix:
	npm run lint:fix

lint-fix-watch:
	npm run lint:fix-watch

# Cleaning
clean:
	rm -rf apps/accessibility/js/
	rm -rf apps/comments/js/
	rm -rf apps/dav/js/
	rm -rf apps/files/js/dist/
	rm -rf apps/files_sharing/js/dist/
	rm -rf apps/files_trashbin/js/
	rm -rf apps/files_versions/js/
	rm -rf apps/oauth2/js/
	rm -rf apps/settings/js/vue-*
	rm -rf apps/systemtags/js/systemtags.*
	rm -rf apps/twofactor_backupcodes/js
	rm -rf apps/updatenotification/js/updatenotification.*
	rm -rf apps/user_status/js/
	rm -rf apps/workflowengine/js/
	rm -rf core/js/dist

clean-git: clean
	git checkout -- apps/accessibility/js/
	git checkout -- apps/comments/js/
	git checkout -- apps/dav/js/
	git checkout -- apps/files/js/dist/
	git checkout -- apps/files_sharing/js/dist/
	git checkout -- apps/files_trashbin/js/
	git checkout -- apps/files_versions/js/
	git checkout -- apps/oauth2/js/
	git checkout -- apps/settings/js/vue-*
	git checkout -- apps/systemtags/js/systemtags.*
	git checkout -- apps/twofactor_backupcodes/js
	git checkout -- apps/updatenotification/js/updatenotification.*
	git checkout -- apps/user_status/js/
	git checkout -- apps/workflowengine/js/
	git checkout -- core/js/dist
