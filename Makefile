build:
	@rm -fr dist docs/slip.html && mkdir dist
	@uglifyjs src/slip.js -m >> dist/min.slip.js
	@./node_modules/.bin/docco src/slip.coffee