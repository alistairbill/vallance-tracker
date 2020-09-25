install:
	stack setup
	stack build --copy-bins
	stack exec js-generation-exe