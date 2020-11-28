#! /bin/bash
set -e
set -o xtrace

rm -rf ./target/
mkdir -p ./target/debug/coverage
DO_ET="fool" LLVM_PROFILE_FILE="${PWD}/target/debug/coverage/test.%p.profraw" RUSTFLAGS="-Zinstrument-coverage" cargo test
git add .
git commit -m "checkpoint2"
git push || true
$(rustc --print target-libdir)/../bin/llvm-profdata merge --sparse ./target/debug/coverage/test.*.profraw -o ./target/test.profdata

# This one works and shows all the details I want in the CLI
$(rustc --print target-libdir)/../bin/llvm-cov show -format=html -instr-profile=./target/test.profdata $(find target/debug/deps -type f -perm -u+x ! -name '*.so') > coverage.html
mv coverage.html ./target

# This one gives an error indicating that there was an error parsing the report
$(rustc --print target-libdir)/../bin/llvm-cov show -instr-profile=./target/test.profdata $(find target/debug/deps -type f -perm -u+x ! -name '*.so') > coverage.txt
mv coverage.txt ./target
# bash <(curl -s https://codecov.io/bash) -f coverage.txt -t <token>

$(rustc --print target-libdir)/../bin/llvm-cov export -format="lcov" -instr-profile=./target/test.profdata $(find target/debug/deps -type f -perm -u+x ! -name '*.so') > lcov.info
mv lcov.info ./target
# This one works, but discards region coverage results and shows the entire line as covered even if only part of it is
# bash <(curl -s https://codecov.io/bash) -f lcov.info -t <token>

# This one gives an error indicating that there was an error parsing the report
$(rustc --print target-libdir)/../bin/llvm-cov export -format="text" -instr-profile=./target/test.profdata $(find target/debug/deps -type f -perm -u+x ! -name '*.so') > coverage.json
mv coverage.json ./target
# bash <(curl -s https://codecov.io/bash) -f coverage.json -t <token>
