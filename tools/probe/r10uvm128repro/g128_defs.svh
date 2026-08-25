// r10uvm128 — the MACRO DEFINITIONS the grid arms invoke.  They live in their
// OWN FILE on purpose: § macroSplitRecvIsAstChain128's gate is that the two
// halves of a written receiver come from TWO DIFFERENT SOURCE BUFFERS, and a
// macro DEFINED AND INVOKED in one file does not have that shape (both halves
// map back into the same file, `rawText` returns a long garbage span and the
// arm never reaches the law).  That is exactly UVM's layout: the macro body is
// `uvm_object_defines.svh`, the argument is written in the class's own file.
//
// The formal is `ARG` (3 characters) throughout, and the arms pass arguments
// of 1, 5, 12 and 20 characters, so no cell can agree with golden by walking
// `start + name.size()` — the argument-paste column shift differs per cell.
`define A128_LOCAL(ARG) \
  begin \
    cls_a128 loc128; \
    if (ARG.size() != loc128.ARG.size()) rc128 = 1; \
    rc128 = rc128 + 1; \
  end
`define A128_HANDWRITTEN(ARG) \
  if (ARG.size() != hand128.ARG.size()) rc128 = 2; \
  rc128 = rc128 + 1;
`define A128_FORMAL(ARG) \
  if (ARG.size() != peer128.ARG.size()) rc128 = 3; \
  rc128 = rc128 + 1;
`define A128_THIS(ARG) \
  if (this.ARG.size() != 0) rc128 = 4; \
  rc128 = rc128 + 1;
`define A128_ALLBODY(ARG) \
  if (hand128.q128.size() != 0) rc128 = 5; \
  rc128 = rc128 + 1;
`define A128_ALLARG(ARG) \
  if (ARG.size() != 0) rc128 = 6; \
  rc128 = rc128 + 1;

// ---- arm B: the PROPERTY kind and the BUILT-IN METHOD ----------------------
`define B128_SIZE(ARG) \
  if (ARG.size()  != ob128.ARG.size())  rc128 = 11; \
  rc128 = rc128 + 1;
`define B128_NUM(ARG) \
  if (ARG.num()   != ob128.ARG.num())   rc128 = 12; \
  rc128 = rc128 + 1;
`define B128_EXISTS(ARG) \
  if (ARG.exists("k") != ob128.ARG.exists("k")) rc128 = 13; \
  rc128 = rc128 + 1;
`define B128_LEN(ARG) \
  if (ARG.len()   != ob128.ARG.len())   rc128 = 14; \
  rc128 = rc128 + 1;
// ---- arm C: WHERE the comparison sits --------------------------------------
`define C128_EQ(ARG) \
  if (ARG.size() == ob128.ARG.size()) rc128 = 21; \
  rc128 = rc128 + 1;
`define C128_NE(ARG) \
  if (ARG.size() != ob128.ARG.size()) rc128 = 22; \
  rc128 = rc128 + 1;
`define C128_LT(ARG) \
  if (ARG.size() <  ob128.ARG.size()) rc128 = 23; \
  rc128 = rc128 + 1;
`define C128_AND(ARG) \
  if (ARG.size() && ob128.ARG.size()) rc128 = 24; \
  rc128 = rc128 + 1;
`define C128_BARE(ARG) \
  rc128 = ob128.ARG.size(); \
  rc128 = rc128 + 1;
`define C128_IF(ARG) \
  if (ob128.ARG.size()) rc128 = 26; \
  rc128 = rc128 + 1;
`define C128_WHILE(ARG) \
  while (ob128.ARG.size() > 99) rc128 = 27; \
  rc128 = rc128 + 1;
`define C128_ARG(ARG) \
  rc128 = f128(ob128.ARG.size()); \
  rc128 = rc128 + 1;
`define C128_TERN(ARG) \
  rc128 = (ob128.ARG.size() > 1) ? 1 : 2; \
  rc128 = rc128 + 1;
// ---- arm D: the HOME -------------------------------------------------------
`define D128_CELL(ARG) \
  if (ARG.size() != ob128.ARG.size()) rc128 = 31; \
  rc128 = rc128 + 1;
// ---- arm E: instance count, spelling, case and order -----------------------
`define E128_ONE(ARG) \
  if (ARG.size() != ob128.ARG.size()) rc128 = 41; \
  rc128 = rc128 + 1;
`define E128_TWO(A1, A2) \
  if (A1.size() != ob128.A2.size()) rc128 = 42; \
                         if (A2.size() != ob128.A1.size()) rc128 = 43; \
  rc128 = rc128 + 1;
