#! /bin/bash
set -e
set -o xtrace

rm -rf ./target/
mkdir -p ./target/debug/coverage
DO_ET="fool" LLVM_PROFILE_FILE="${PWD}/target/debug/coverage/test.%p.profraw" RUSTFLAGS="-Zinstrument-coverage" cargo test
$(rustc --print target-libdir)/../bin/llvm-profdata merge --sparse ./target/debug/coverage/test.*.profraw -o ./target/test.profdata

# This one works and shows all the details I want in the CLI
$(rustc --print target-libdir)/../bin/llvm-cov show \
	-format=html \
	-Xdemangler=rustfilt \
	-show-instantiations \
	-output-dir=./target/debug/coverage-html \
	-ignore-filename-regex="${HOME}/*" \
	-instr-profile=./target/test.profdata \
	$(find target/debug/deps -type f -perm -u+x ! -name '*.so')
