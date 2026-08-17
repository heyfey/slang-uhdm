# TAP.md — the `Instance()` tap that found the site in one build

`r10sd2` §2 named four `ParamEmit.cpp` sites and one `TaskFuncEmit.cpp` site as
the candidates for § instanceIsNeverAClassDefn2, by grepping C-style casts.
**All five are wrong** (r10sd3 README §3). The site is `ModuleEmit.cpp:20876`.

Reasoning about ~100 setter call sites is what produced the wrong answer twice.
The tap answers it mechanically in **one throwaway build**, and is reproduced
here so the next pass does not re-derive it. It is a DEBUG artifact: it is not in
the delivered patch and must never be built into a binary that produces a
measured artifact.

## 1. Rewrite every setter call

`r10sd3_tap.py` (below) finds every `->Instance(<arg>)` whose next character is
not `)` (that is the getter), matches the closing paren by depth so multi-line
calls and nested calls survive, and wraps the argument:

```
X->Instance(ARG)   ->   X->Instance(sd3tap(__FILE__,__LINE__,ARG))
```

Run over `src/*.cpp` this wraps **179** calls:
`ExprEmit 15, ModuleEmit 38, ParamEmit 61, StmtEmit 5, TaskFuncEmit 16,
TypeEmit 38, UhdmExporter 6`.

```python
#!/usr/bin/env python3
import os, sys
root = sys.argv[1]
files = [os.path.join(root, 'src', f)
         for f in sorted(os.listdir(os.path.join(root, 'src')))
         if f.endswith('.cpp')]
total = 0
for path in files:
    txt = open(path).read()
    out, i, n = [], 0, 0
    while True:
        j = txt.find('->Instance(', i)
        if j < 0:
            out.append(txt[i:]); break
        k = j + len('->Instance(')
        if txt[k] == ')':                      # getter
            out.append(txt[i:k]); i = k; continue
        depth, p = 1, k
        while p < len(txt) and depth:
            c = txt[p]
            if c == '(': depth += 1
            elif c == ')':
                depth -= 1
                if depth == 0: break
            p += 1
        out.append(txt[i:k]); out.append('sd3tap(__FILE__,__LINE__,')
        out.append(txt[k:p]); out.append(')')
        i = p; n += 1
    if n:
        open(path, 'w').write(''.join(out)); total += n
        print(f'{os.path.basename(path)}: {n}')
print('TOTAL wrapped:', total)
```

## 2. The helper

Inserted in `include/UhdmExporter.h` immediately before `namespace slang_uhdm {`
— i.e. **after** `#include <uhdm/uhdm.h>`, which every `*Emit.cpp` gets through
this header. A single non-template function taking `UHDM::instance*` is enough:
every argument at every call site is already convertible to it (`package*`
derives from `instance*`, and the class_defn cases arrive through an explicit
C-style cast), and `nullptr` converts unambiguously.

```cpp
#include <cstdio>
#include <map>
#include <string>
inline UHDM::instance* sd3tap(const char* f, int l, UHDM::instance* v) {
    static std::map<std::string, int>* seen = new std::map<std::string, int>();
    if (v && ((const UHDM::BaseClass*)v)->UhdmType() == UHDM::uhdmclass_defn) {
        std::string k = std::string(f) + ":" + std::to_string(l);
        int n = ++(*seen)[k];
        if (n == 1 || n % 100 == 0)
            fprintf(stderr, "SD3TAP %s n=%d\n", k.c_str(), n);
    }
    return v;
}
```

Change the `UhdmType()` test to select a different value shape; the mechanism is
otherwise identical for any "who wrote this pointer" question.

## 3. THE TRAP — do not accumulate and print from a destructor

The first version accumulated into `taps()` (a function-local `static
std::map`) and printed from a namespace-scope `static` dumper object. The map is
constructed on first use **during** `main` and destroyed **before** the
namespace-scope object, so the dumper reads freed memory:

```
SD3TAP 0Re<garbage> 526
```

— a plausible-looking count attached to an unreadable key, and it cost a full
rebuild. **Leak the map** (`new`, never deleted) and print at tap time, as above.

## 4. Run it

```sh
git worktree add --detach /tmp/wt_r10sd3dbg <BASE>
python3 r10sd3_tap.py /tmp/wt_r10sd3dbg
#   ...insert the helper into include/UhdmExporter.h...
cmake -S /tmp/wt_r10sd3dbg -B /tmp/wt_r10sd3dbg/build -DCMAKE_BUILD_TYPE=Release
cmake --build /tmp/wt_r10sd3dbg/build -j 2          # WAIT for the link line
cd ~/git-repos/Surelog/third_party/tests/SeqDriver
/tmp/wt_r10sd3dbg/build/slang-uhdm <the row's own cmds.txt args> -o /tmp/x.uhdm 2>tap.err
grep ^SD3TAP tap.err | sort -u
```

The row's argv comes out of its `cmds.txt`, and the binary must be run **from
the test's own directory** — `verify_golden.py` runs it with `cwd=dirpath`, and
from anywhere else the relative sources do not resolve (`rc=2`, no tap output at
all).

Result for § instanceIsNeverAClassDefn2, whole SeqDriver run:

```
SD3TAP /tmp/wt_r10sd3dbg/src/ModuleEmit.cpp:20876 n=1 … n=500
```

**One site. 526 stamps.** 428 survive into the database.
