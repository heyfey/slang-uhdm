r10earl54 LADDER PREDICTION — written BEFORE lad_pat3.txt was read.
Family constant|VpiType|KIND:constant>operation, fresh pristine run at 5bd0a3a
(NOT the older base file the README quoted): 44 rungs.

The census (exhaustive, 99 movers) names exactly two sites:
  tlul_fifo_sync.sv:76:69-76:91   98 objects  -> 36 ladder rungs reach it
  clkmgr_pkg.sv:38:11-38:20        1 object   ->  1 ladder rung
So 37 of the 44 family rungs must CLEAR and 7 must REMAIN:
  :0:0-0:0                      3   loc-less, no replication
  flash_ctrl.sv:137:18-137:30   1   unpacked-array-of-struct element select
  pinmux_pkg.sv:20:32-20:39     1   not a conn-nested replication
  alert_handler.sv:87:27-87:51  1   ditto
  pwrmgr_pkg.sv:156:14-156:32   1   the R4 WIDTH CAST (deliberately excluded)
PREDICT: family 44 -> 7, tlul 36 -> 0, clkmgr 1 -> 0.

=== MEASURED (both runs --max=20000 --budget=1500, run ALONE, back-to-back) ===

pristine: [S] rungs=3113 stop=BUDGET escalated=193 ref_joins=0 nofield=0 maxvis=610086/783183 masks=3113 cascades=20 suppressed=638600/783183 secs=1500.2
patched : [S] rungs=3103 stop=BUDGET escalated=194 ref_joins=0 nofield=0 maxvis=620243/783183 masks=3103 cascades=20 suppressed=638600/783183 secs=1500.1

rungs: pristine=3113 patched=3103
CLEARED (a pristine rung whose golden site is gone) = 37
NEW     (a patched rung with no pristine twin)      = 26
KEPT                                                = 3036
-- CLEARED by family
   constant|VpiType|KIND:constant>operation             37

VERDICT: family 44 -> 7, tlul 36 -> 0, clkmgr 1 -> 0.  PREDICTION EXACT.
The 26 NEW rungs are int_typespec>integer_typespec, a PRE-EXISTING family
(pristine 333 rungs, patched 359): the patched walk reaches ~10k objects
deeper in the same budget because 37 rungs no longer need masking.
