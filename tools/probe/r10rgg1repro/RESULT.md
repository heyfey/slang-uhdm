# r10rgg1 — RESULT

* **Rggen does NOT pass `uhdm-cmp`** and could not: its head is ladder rung 1,
  the Surelog `setValueInInstance` compound-assign write-back that MUTATES the
  function body's literal in place (README §1).  Named, mechanised, gridded,
  and deliberately NOT emulated.  This is the wall the next pass must model.
* Ladder `default:Rggen` **98 → 70 rungs** (FIXPOINT both), the two largest
  non-head families to ZERO, no new family, rung 1 byte-identical.
* Database delta: **44** fresh elab cont_assigns matching golden's 44, **2**
  param_assign constant encodings, nothing else.
* Row statuses: **0 differing rows** over uhdm2rtlil 1462 and surelog 1588,
  against the COMMITTED baselines, from both binaries.  All canaries
  byte-identical, YosysVerx and SVSwitch at their pins.
* Byte movers: 2 of 953; `Rggen` is mine and attributed, `Scoreboard` is proven
  base-binary nondeterminism (4 base runs, 3 give the patched hash).
* The brief's shared-family premise is **REFUTED by measurement**: Earlgrey
  shares the FAM label and not the mechanism, and is byte-identical.
* Residues R1-R4 named with golden's exact answer for each (README §4).
