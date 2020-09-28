#!/usr/bin/env sh
tmp_dir=$(mktemp -d)
stack exec vallance-tracker-exe -- --generate-swagger > $tmp_dir/api.json
swagger-codegen generate -l typescript-fetch -i $tmp_dir/api.json -o frontend/src/generated