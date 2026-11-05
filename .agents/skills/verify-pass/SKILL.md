---
name: verify-pass
description: "How to adversarially verify another agent's slang-uhdm fix before it lands: rebuild both binaries, reproduce every number, attack the law with new cases on legal SystemVerilog, fix what breaks, ship the verified patch and a verdict. Use when you are the verifier of a pass."
---

# Verifying a pass

The implementer's report is a claim. Your job is to break it. About half of
the campaign's landings needed a verifier fix, and several verifiers found
segfaults on legal SystemVerilog that no gate would have shown. Work in your
own worktree at the same base commit, under `tools/probe/v11u<N>repro/`.
Job counts are the defaults of AGENTS.md; the user's prompt overrides them.

## 1. Rebuild and reproduce

1. `git worktree add /tmp/wt_v11u<N> <base>`; apply the implementer's patch
   with `git apply -3`; build both the pristine and the patched binary
   (`cmake --build build -j 2`, `Built target`); freeze copies; record md5s.
2. Reproduce **every** headline number of the implementer's README with your
   own binaries: the grid verdicts per cell, the predicted movers, the gate
   counts. A number you cannot reproduce is a finding, not a typo.
3. Audit the patch for collateral: edits to `results/*.csv`, stray files,
   drivers hard-coding another pass's paths, `rm -rf` on shared scratch, any
   command that dispatches a fenced test (tests/FENCED.md; names only from
   the `FENCED=` line of `tools/probe/r11u107repro/canaudit.sh`).

## 2. Attack the law

Write new cases along axes the implementer's grid did not vary: declaration
order, names (a grid that names everything `a_t`, `b_t` over `A`, `B` is
self-confirming), scopes (package, module, interface, generate, function,
class), one versus several instances or importers, typedef'd versus anonymous,
def view versus elab view, the law's abstain conditions at their boundary.
Run each case through `scripts/converge.sh` on **both** binaries and classify
every cell:

| pristine | patched | meaning |
|---|---|---|
| wrong | right | the law works here |
| wrong | wrong | residue: record the first differing object |
| right | right | not a test of the law unless the mechanism is the law's |
| right | wrong | **a break**: fix it |

Also run the implementer's own cases with the law switched off
(`R11U<N>_<LAW>_OFF=1`): the output must equal the pristine binary's byte for
byte, or the switch does not cover the change.

## 3. Fix breaks yourself

A pristine-right, patched-wrong cell on legal SystemVerilog is fixed by you:
the smallest switched change, the implementer's law name kept, your fix
under the same switch or a `fixOn(<N>, "R11V<N>_<X>_OFF")` of its own. Re-run
the whole battery (the implementer's grid, your attack grid, the full gate
with claim-equal §4). Ship `/tmp/r11u<N>.verified.patch` = `git diff <base>`
of the fixed tree.

## 4. Verdict

`tools/probe/v11u<N>repro/README.md`: ACCEPT, ACCEPT-WITH-FIX (what broke,
the fix, the re-run numbers) or REJECT (what could not be reproduced or what
breaks without a fix); the attack grid table; the residues ranked; the
switch-off identity check. The final text of the report is the numbers, not
prose. Your cases that judge EQUAL or STRICT_NOTEQUAL on the verified binary
move to `tests/probe/v11u<N>repro/...` with a `LAW` file, like the
implementer's.
