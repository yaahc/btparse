#! /bin/bash
set -e
set -o xtrace

rm -rf ./target/
mkdir -p ./target/debug/coverage
DO_ET="fool" LLVM_PROFILE_FILE="${PWD}/target/debug/coverage/test.%p.profraw" RUSTFLAGS="-Zinstrument-coverage" ZEBRA_SKIP_NETWORK_TESTS=1 cargo test
git add .
git commit -m "checkpoint"
git push
$(rustc --print target-libdir)/../bin/llvm-profdata merge --sparse ./target/debug/coverage/test.*.profraw -o test.profdata
$(rustc --print target-libdir)/../bin/llvm-cov show -Xdemangler=rustfilt -instr-profile=test.profdata $(find target/debug/deps -type f -perm -u+x ! -name '*.so') -show-line-counts-or-regions -show-instantiations > coverage.txt
$(rustc --print target-libdir)/../bin/llvm-cov export -format="lcov" -instr-profile=test.profdata $(find target/debug/deps -type f -perm -u+x ! -name '*.so') > lcov.info
$(rustc --print target-libdir)/../bin/llvm-cov show -Xdemangler=rustfilt -instr-profile=test.profdata $(find target/debug/deps -type f -perm -u+x ! -name '*.so') -show-line-counts-or-regions -show-instantiations
mv lcov.info ./target
# bash <(curl -s https://codecov.io/bash) -f lcov.info
