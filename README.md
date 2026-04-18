# Lib65816
Emulator library for the 65816 CPU.<br>
See https://codebutchery.wordpress.com/65816-cpu-emulator/

Disclaimer:
I didn't test this enough to claim that it works well, you are free to use it but you might have to do some bugfixing :)

## Smoke Test

There is now an in-repo smoke test that assembles a small `65816` program with `64tass`
and runs it through the library.

Requirements:

- `cmake`
- `64tass`

Build and run:

```bash
cmake -S . -B build-smoke -DCMAKE_BUILD_TYPE=Debug -DBUILD_SMOKE_TEST=ON
cmake --build build-smoke -j1 --target smoke65816
```

This builds the library, assembles `tests/smoke/65816_smoke.asm`, and runs the
`run65816_smoke` harness.
