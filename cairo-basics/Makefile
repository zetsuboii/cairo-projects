# Build and test
build :; nile compile
test  :; pytest tests/

compile-fifteen:
	cairo-compile contracts/fifteen.cairo --output=artifacts/fifteen_compiled.json

run-fifteen:
	cairo-run --program=artifacts/fifteen_compiled.json --program_input=fifteen_input.json \
	--print_output --layout=small

# Find Key

compile-findkey:
	cairo-compile contracts/findkey.cairo --output=artifacts/findkey_compiled.json

run-findkey:
	cairo-run --program=artifacts/findkey_compiled.json \
	--print_output --layout=small