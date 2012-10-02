
REPORTER = dot

doc:
	@./node_modules/.bin/coffee lib/doc $(RON_DOC)

test:
	@NODE_ENV=test ./node_modules/.bin/mocha --compilers coffee:coffee-script \
		--reporter $(REPORTER)

.PHONY: test
