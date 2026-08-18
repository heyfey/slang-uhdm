r10earl63 — THE ArrayExprFuncArg ABLATION (fence F4 of § constCallFoldAdjustSize63).

Four one-difference copies of Surelog's tests/ArrayExprFuncArg/dut.sv, each run
  surelog -parse -d uhdm -elabuhdm dut.sv -nobuiltin
and read with pacen63:

  abl_a  the file verbatim                          ELAB MAX_VADDR  BIN:…101 sz32
  abl_b  VADDR is the LITERAL '{3,5,4}              ELAB MAX_VADDR  UINT:5   sz32
  abl_c  a, minus the three generate-if reads       ELAB MAX_VADDR  BIN:…101 sz32
  abl_d  b, minus the three generate-if reads       ELAB MAX_VADDR  UINT:5   sz32

=> the ARGUMENT decides (an unpacked array produced by an unreduced const-call
   folds BIN; the same array written as a literal pattern folds UINT); the
   generate-if reads are inert.  f6_earl63.sv is the same shape rebuilt from
   scratch with a literal array and reads UINT in golden, which is why the
   fence is written on the ARGUMENT TYPE and not on the function body.
