# r10uvm101 — event trigger syntax-base names

## Result

`event_stmt::VpiName` follows Surelog's written-syntax behavior for event
triggers.  A blocking or untimed nonblocking trigger takes the first written
token of its target (`m_events`, `this`, a handle, or an instance name), not the
bound leaf event symbol.  A timed nonblocking trigger remains nameless because
Surelog attempts to compile the intervening timing node.  Surelog also stamps
`vpiBlocking` on both trigger spellings.

The implementation accepts only Identifier and ThisKeyword base tokens.
`$root` was deliberately excluded after the adversarial token grid showed that
Surelog leaves it nameless; `super` is rejected by Surelog's parser.  Written
paths use syntax.  Syntax-less synthesized statements retain the prior direct
symbol fallback.

## Decoded producer

Surelog `CompileStmt.cpp:814-827` compiles the syntax node immediately after the
trigger token and copies the resulting expression's `VpiName` to the
`event_stmt`.  This explains the first-token names and the timed-trigger hole;
the trigger-type test also misses the grammar token and sets blocking in both
forms.  The implementation is in `src/StmtEmit.cpp` under
`eventTriggerSyntaxBaseName101`.

## Acceptance

The final, syntax-less-fallback-only candidate was rebuilt on base `9a9b70d7`
and frozen at binary MD5 `9ae62f2d6a19f72cf5cb259847914b9a`.  All 1,588 Surelog rows and both 731-row
uhdm2rtlil modes remain byte-identical to the base controls.  The Surelog byte
census has exactly nine predicted movers; uhdm2rtlil has zero.  Across the nine
comparable UVM databases, 52 event fields move to golden and none move away or
remain wrong.  The three adversarial grids contribute 42 source-site/view
moves to golden with zero away-golden or still-wrong cells.  See `GRID.txt`,
`CENSUS.txt`, `GATES.txt`, and `BOUNDARY.txt`.

The official heads after this slice are SeqDriver 17 lines / one head and
MiniAmiq 348 / one in both modes.  MiniAmiq's larger line count is the next
deeper mismatch exposed after its event-statement head clears; the measured
event fields themselves equal golden.

Integration audit note: the host-side edit mirror was refreshed from the
current mainline before the final build.  This preserves the accepted
`foreachPkgClassArrayVar25` rule; a focused BuildUVMPkg check confirms its
`uvm_init::idx` remains an `array_var` before the full sweeps.
