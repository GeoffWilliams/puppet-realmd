all:
	cd .pdqtest && bundle exec pdqtest all
	$(MAKE) docs

fast:
	cd .pdqtest && bundle exec pdqtest fast

shell:
	cd .pdqtest && bundle exec pdqtest --keep-container acceptance

setup:
	cd .pdqtest && bundle exec pdqtest setup

shellnopuppet:
	cd .pdqtest && bundle exec pdqtest shell

logical:
	cd .pdqtest && bundle exec pdqtest syntax
	cd .pdqtest && bundle exec pdqtest rspec
	$(MAKE) docs

nastyhack:
	# fix for - https://tickets.puppetlabs.com/browse/PDK-1192
	find vendor -iname '*.pp' -exec rm {} \;

bundle:
	# Install all gems into _normal world_ bundle so we can use all of em
	cd .pdqtest && bundle install

docs:
	cd .pdqtest && bundle exec "cd ..&& puppet strings"



