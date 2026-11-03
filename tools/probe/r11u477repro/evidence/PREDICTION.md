# Prediction written before the law sweep (r11u477, law binary law6)

Source: census.tsv (pristine vs law6 traced, every fence-filtered row-mode from its own directory, no Surelog run).

- Exit codes: no row-mode moves (0 of 10616).
- Byte movers (46):
  - surelog: BlackBePipeInt d/t, Earlgrey_0_1 d/t, YosysOldOpen d/t (§ caAddLeafIntMint477; Earlgrey also § parenCallWrittenArgs477 firing). Dumps identical to pristine's (the serialized string table differs: an intermediate UINT string no longer stored); all six STRICT_EQUAL against golden on both binaries (339479/338504, 2173209/1342584, 31337/31337 objects). Status unchanged, no strict change.
  - probe: 39 cases (§ caAddLeafIntMint477), all 39 dump-identical to pristine: no verdict can move.
  - uhdm2rtlil, downstream: no byte mover.
  - sv-tests: generated/easyUVM/top.sv only (all four laws fire); stays DIFFERENT, its uhdm-cmp head moving from comparator.sv 63:14 (the defaulted argument) past the included interfaces' import copies to the definition top's ref_module listing (ModuleEmit, the sister's ground).
- Conversions expected: none in any gate. Changes expected: none (easyUVM's detail column may change, it is DIFFERENT either way).
