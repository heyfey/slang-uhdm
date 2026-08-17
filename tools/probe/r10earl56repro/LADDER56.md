r10earl56 LADDER PREDICTION — written BEFORE either matched-budget run started.

The site key `ladcmp56.py` joins on is golden's printed identity INCLUDING its
`#UhdmId`, so it is injective.

§ genScopeOwnParamNoSelFold56 makes EXACTLY 254 golden objects compare equal —
the census says so (TO-GOLDEN 254, AWAY 0, STILL-WRONG 0 over 32 505 paired
select-bound slots) and the whole-dump diff says so independently (254 added
ref_objs, 254+254+508 removed constants/typespecs, nothing else in 4.7 M lines).

PREDICT
  CLEARED >= 2 and every CLEARED rung is in the family
            `ref_obj|VpiType|KIND:ref_obj>constant`, at prim_fifo_sync.sv 70:38
            or 71:38.  The 12-rung pristine ladder carries exactly TWO such
            rungs (#291403 and #291408, the i_dm_csrs.i_fifo pair) inside its
            budget; a 1500 s walk reaches many more of the 127 instances, so the
            CLEARED count should be roughly 2 x (instances reached) and every
            one of them must be a PTRV_W ips WIDTH cell.
  A CLEARED rung ANYWHERE ELSE would be a finding: this law touches one
            identifier in one file.
  The family does NOT go to zero design-wide unless the walk reaches all 127
            instances; a "family cleared" claim would be unsafe.
  KEPT      must include rung 9's OPPOSITE-direction cell
            (`constant@prim_fifo_sync.sv:131:29 > ref_obj(PTR_WIDTH)`,
            FAM=`constant|VpiType|KIND:constant>ref_obj`) — it is R3, the family
            this pass's head is the reversed member of, and this pass does not
            touch it.  If it disappeared, the fence would have leaked.
  KEPT      must include rungs 3-8, the `int_typespec>integer_typespec` DepthW
            family, one of which is the NEW HEAD.
  NEW rungs > 0 are EXPECTED and are NOT new defects: 254 fewer defects means
            the patched walk gets deeper in the same wall clock and reaches
            cells the pristine run never looked at.  A NEW rung in a family the
            pristine ladder does NOT already carry would be a real finding.

=== MEASURED (both runs --max=20000 --budget=420, run back-to-back) ===

pristine: [S] rungs=1037 stop=BUDGET escalated=133 maxvis=472231/783183 masks=1037 cascades=17 suppressed=638600/783183 secs=420.2
patched : [S] rungs=871  stop=BUDGET escalated=67  maxvis=471486/783183 masks=871  cascades=17 suppressed=638600/783183 secs=420.3

BUDGET NOTE, stated because it is a real limitation of this measurement and not
an excuse: the budget is WALL CLOCK and this machine was NOT idle (other agents'
`cc1plus` processes were running during both runs).  Both runs took the same
420 s and reached comparable DEPTH — 472 231 vs 471 486 golden objects proven
equal — but the patched run got through FEWER rungs (871 vs 1037).  earl55 ran
1 500 s per side on an idle machine; this pair is a quarter of that.

`ladcmp56.py` reports:

    rungs: pristine=1037 patched=871
    CLEARED = 166      NEW = 0      KEPT = 839
    -- CLEARED by family
       constant|VpiType|KIND:constant>ref_obj      100
       ref_obj|VpiType|KIND:ref_obj>constant        66

AND THE 100 IS NOT A FIX.  `ladidx56.py` (written for this pass, because
`ladcmp56.py` has no such guard) separates the two things a site-absence can
mean:

    COMPARISON HORIZON = pristine rung 937
      (the last pristine site still present in the patched ladder)

    CLEARED   (index <= horizon)  =  66   ref_obj>constant   idx 1..500
    UNREACHED (index >  horizon)  = 100   constant>ref_obj   idx 938..1037

All 100 `constant>ref_obj` "cleared" rungs sit at pristine indices 938-1037 —
BEYOND the patched walk's horizon. They were never looked at. Claiming them
would have been claiming 100 fixes in the OPPOSITE-direction family this pass
explicitly does not touch, and the census (AWAY-GOLDEN 0, DISAGREE 2 355 →
2 101 = exactly -254) and the whole-dump diff (254 added ref_objs, nothing else)
both say they are untouched.

VERDICT, against the prediction written above:
  * CLEARED >= 2, all in `ref_obj|VpiType|KIND:ref_obj>constant`, all at
    prim_fifo_sync.sv 70:38 / 71:38 — **MEASURED: 66, every one of them a
    PTRV_W ips WIDTH cell**, and `PTRV_W` rungs in the patched ladder = **0**
    (pristine 66).  33 of the design's 127 `gen_normal_fifo` instances were
    reached inside the horizon, two rungs each.
  * NEW = 0 — the patched walk is a prefix of the pristine one minus the fixed
    rungs, which is the cleanest possible shape for this join.
  * KEPT includes the OPPOSITE-direction cell the prediction named:
    `constant@prim_fifo_sync.sv:131:29 > ref_obj(PTR_WIDTH)` is still there
    (it is R3, and the first build of this law WRONGLY cleared its 127:48
    sibling — see README's regression section).
  * earl54's control family `constant|VpiType|KIND:constant>operation` is
    pristine 3 / patched 3 and `tlul_fifo_sync.sv:76:69-76:91` is 0 / 0 —
    exactly where earl54 left it.
  * The prediction's line "a CLEARED rung ANYWHERE ELSE would be a finding" was
    right to be written: the run DID produce 100 of them, and the finding is
    that `ladcmp56.py` cannot tell "fixed" from "not reached". That instrument
    gap is now closed by `ladidx56.py`.
