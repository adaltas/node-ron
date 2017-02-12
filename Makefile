
REPORTER = dot

doc: build
	@./node_modules/.bin/coffee src/doc $(RON_DOC)

.PHONY: test
