r10earl55 LADDER PREDICTION — written BEFORE either matched-budget run started.

The site key `ladcmp55.py` joins on is golden's printed identity INCLUDING its
`#UhdmId`, so it is injective even for a LOC-LESS object whose span prints as
`:0:0-0:0` for hundreds of distinct typespecs.  That matters here: this pass's
head IS such an object.

§ replFoldTsW1 makes EXACTLY ONE golden object compare equal — the census says
so (TO-GOLDEN 1, AWAY 0, STILL-WRONG 0 over 10 822 paired param_assign cells),
and gate 5 says so independently (2 311 databases, one mover).

PREDICT
  CLEARED = 1, and it is exactly `int_typespec@:0:0-0:0#288957`, family
            `int_typespec|VpiType|KIND:int_typespec>logic_typespec`.
  Every other pristine rung is KEPT.  In particular the 32-bit sibling of the
  head (u_pinmux.MioPeriphHasSleepMode, R1) must SURVIVE if the walk reaches it:
  it is the same FAMILY as the head and a family-level reading would wrongly
  claim it.
  NEW rungs > 0 are EXPECTED and are NOT new defects: one fewer mask means the
  patched walk gets deeper inside the same wall-clock budget and REACHES cells
  the pristine run never looked at.  earl54 measured exactly this (26 NEW rungs,
  all in a family the pristine run already carried 333 of).  Any NEW rung in a
  family the pristine ladder does NOT already carry would be a real finding.
  The dominant NEW family, if the walk gets far enough, should be
  `int_typespec>integer_typespec` at prim_fifo_sync/tlul_socket_1n — rungs 4-8
  of `lad_pris8.txt` are already in it.

SHARPENED once the pristine run finished (still BEFORE the patched run existed):
the pristine ladder carries EXACTLY TWO rungs in the head's family
`int_typespec|VpiType|KIND:int_typespec>logic_typespec` —
  #288957  ref_typespec{work@top_earlgrey.u_dm_top}   <- rv_dm.sv:50  (THE HEAD)
  #595640  ref_typespec{work@top_earlgrey.u_pinmux}   <- pinmux.sv:54  (R1, 32 bits)
(owners resolved with tsown55, not guessed.)  So the family goes 2 -> 1, and a
report that said "the family is cleared" would be wrong by one rung.

=== MEASURED (both runs --max=20000 --budget=1500, run ALONE, back-to-back) ===

pristine: [S] rungs=3424 stop=BUDGET escalated=252 ref_joins=0 nofield=0 maxvis=632269/783183 masks=3424 cascades=20 suppressed=638600/783183 secs=1500.6
patched : [S] rungs=3442 stop=BUDGET escalated=254 ref_joins=0 nofield=0 maxvis=632907/783183 masks=3442 cascades=20 suppressed=638600/783183 secs=1500.2

(The two runs reach comparable depth — 632 269 vs 632 907 golden objects proven
equal — which is what makes the join fair.  Run ALONE, back-to-back, nothing else
on the machine: the budget is WALL CLOCK, so a concurrent job would make the
patched walk look shallower and the comparison would be worthless.)

rungs: pristine=3424 patched=3442
CLEARED (a pristine rung whose golden site is gone) = 1
NEW     (a patched rung with no pristine twin)      = 19
KEPT                                                = 3380

-- CLEARED by family
   int_typespec|VpiType|KIND:int_typespec>logic_typespec   1
     rung 1   int_typespec@:0:0-0:0#288957

VERDICT: PREDICTION EXACT.  The family goes 2 -> 1; the CLEARED rung is the
head object #288957 and nothing else; the family's other member #595640
(u_pinmux, 32 bits, R1) is still there in the patched ladder, exactly as
predicted — a "family cleared" claim would have been wrong by one rung, and the
prediction said so before the run.

-- NEW by family (19), and EVERY ONE is a family the PRISTINE ladder already
   carries, i.e. cells the pristine walk never reached, not new defects:
   tagged_pattern>hier_path                        9   (pristine carries 249)
   int_typespec>integer_typespec                   4   (pristine carries 455)
   ref_obj>constant                                2   (pristine carries 120)
   constant|VpiDecompile|TEXT:#'b#|#               2   (pristine carries  28)
   hier_path|VpiName|…a_source[IDW - #-:#]         1   (pristine carries  16)
   tagged_pattern>ref_obj                          1   (pristine carries  31)
   First new site: tlul_socket_m1.sv:105:33 — 18 of the 19 are in
   tlul_socket_m1.sv, which the pristine run's budget stopped just short of.
   Freed of ONE mask the patched walk gets ~640 objects deeper in the same
   1 500 s, and that is the whole of the delta.

-- CONTROL, printed by ladcmp55.py: family constant|VpiType|KIND:constant>operation
   pristine=7 patched=7, of which tlul_fifo_sync.sv:76:69-76:91 pristine=0
   patched=0 — earl54's family is still exactly where earl54 left it (44 -> 7),
   so this pass neither un-fixed nor re-fixed it.
