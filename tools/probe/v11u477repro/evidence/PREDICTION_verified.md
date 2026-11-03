# Prediction for the verified-binary sweep (written 2026-11-03 04:21:20 before it ran)

verified = law + § paramEncNoAddLeaf477v (md5 f430c65a529a2495885bc69cf3c6d5f1).
The fix only disables § caAddLeafIntMint477's leaf rule while analyzeParamEnc
computes the paramIntEnc marker, so verified differs from law only where that
marker is read with an observable effect.

- Every stage's csv equal to the law sweep's (probe 4024 + 63, surelog 480 + 0 / 474 + 0,
  uhdm2rtlil 803/1/67 both modes, downstream 803/66/2/0, sv-tests unchanged, 0/0/0 everywhere).
- surelog: the six law movers (BlackBePipeInt, Earlgrey_0_1, YosysOldOpen, d/t) keep the law's
  bytes: measured beforehand by running the verified binary traced on those three rows
  (paramEncNoAddLeaf477v fires 406 times there, every database byte-identical to the law sweep's).
- uhdm2rtlil and downstream: 0 movers against the law sweep (0 against the control on law).
- probe: no verdict moves; any byte mover is among the law's movers.
- sv-tests: every row keeps its status; easyUVM keeps the law's head.
