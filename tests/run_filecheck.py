
#!/usr/bin/env python3
"""Run OptForge, verify LLVM IR, and check expected output."""

import argparse
import subprocess
import sys


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--opt", required=True)
    parser.add_argument("--filecheck", required=True)
    parser.add_argument("--plugin", required=True)
    parser.add_argument("--input", required=True)

    args = parser.parse_args()

    run = subprocess.run(
        [
            args.opt,
            "-load-pass-plugin", args.plugin,
            "-passes=function(optforge-simplify)",
            "-verify-each",
            "-S",
            args.input,
        ],
        text=True,
        capture_output=True,
        check=False,
    )

    if run.returncode != 0:
        print(run.stderr, file=sys.stderr)
        return run.returncode

    check = subprocess.run(
        [args.filecheck, args.input],
        input=run.stdout,
        text=True,
        capture_output=True,
        check=False,
    )

    if check.returncode != 0:
        print(check.stderr, file=sys.stderr)
        print(
            "\nOptimized IR:\n",
            run.stdout,
            file=sys.stderr,
        )
        return check.returncode

    print("PASS:", args.input)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

