# OptForge

A C++ LLVM optimization framework built as a series of progressively more advanced
LLVM New Pass Manager plugins. Phase 1 implements a function-level algebraic
identity simplification pass.

## Requirements

- LLVM 22 (headers, `opt`, `FileCheck`)
- CMake 3.20+
- Ninja
- Python 3
- C++17 compiler

On macOS with Homebrew:

```sh
brew install llvm@22 cmake ninja
export LLVM_ROOT="$(brew --prefix llvm@22)"
```

## Build

```sh
cmake -S . -B build -G Ninja \
  -DLLVM_DIR="$LLVM_ROOT/lib/cmake/llvm" \
  -DCMAKE_CXX_COMPILER="$LLVM_ROOT/bin/clang++"
cmake --build build
```

## Run

```sh
PLUGIN="$(find build -type f \( -name 'OptForgePass.dylib' -o -name 'OptForgePass.so' \) -print -quit)"
"$LLVM_ROOT/bin/opt" -load-pass-plugin "$PLUGIN" \
  '-passes=function(optforge-simplify)' -verify-each -S \
  examples/demo.ll -o build/demo.optimized.ll
cat build/demo.optimized.ll
```

## Test

```sh
ctest --test-dir build --output-on-failure
```

The tests verify transformed IR using LLVM FileCheck and check IR validity
with LLVM's pass verifier. The pass deliberately handles scalar integer
identities only; it does not yet fold constants, eliminate all dead code,
or optimize floating point operations.

## Current identities

- `x + 0`, `0 + x` -> `x`
- `x - 0` -> `x`
- `x * 1`, `1 * x` -> `x`
- `x & -1`, `-1 & x` -> `x`
- `x | 0`, `0 | x` -> `x`
- `x ^ 0`, `0 ^ x` -> `x`
- `x << 0`, `x >> 0` -> `x` (LLVM `shl`, `lshr`, `ashr`)
- `x / 1` -> `x` (LLVM `udiv`, `sdiv`)

## Roadmap

1. Phase 1: Out-of-tree pass plugin + algebraic identities (current)
2. Phase 2: Constant folding and propagation + dead-code elimination
3. Phase 3: Local common subexpression elimination and value numbering
4. Phase 4: Control-flow simplification, constant branches, PHI correctness
5. Phase 5: Dominator-aware global value numbering and data-flow analysis
6. Phase 6: Loop-invariant code motion and strength reduction
7. Phase 7: Composed pipelines, differential correctness tests, benchmarks, CI

## References

- https://llvm.org/docs/WritingAnLLVMNewPMPass.html
- https://llvm.org/docs/CMake.html
- https://llvm.org/docs/LangRef.html
