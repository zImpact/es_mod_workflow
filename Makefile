.PHONY: lint-actionlint lint-yamllint lint

lint-actionlint:
	actionlint

lint-yamllint:
	yamllint .

lint: lint-actionlint lint-yamllint
