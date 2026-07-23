# cmptool — semantic UHDM comparator

Wraps UHDM's `design->Compare` (the same check as `uhdm-cmp`; DESIGN r=0 <=> PASS_CMP)
and adds diagnostics:

- per-container breakdown (AllModules/TopModules/AllPackages/AllInterfaces)
- failing pair with human-readable type names
- `lhsPath:`/`rhsPath:` parent-chain container paths for the failing objects

Build:
    g++ -O2 -std=c++17 main.cpp -I ~/.local/include -L ~/.local/lib64 -luhdm -lcapnp -lkj -o cmptool

Usage:
    cmptool <surelog.uhdm> <slang.uhdm>       # DESIGN line is authoritative
    CMP_DECOMPILE=1 cmptool a.uhdm b.uhdm     # also decompile the failing pair
