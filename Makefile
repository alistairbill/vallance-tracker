install:
	stack setup
	stack build --copy-bins
	vallance-tracker-exe --generate-js