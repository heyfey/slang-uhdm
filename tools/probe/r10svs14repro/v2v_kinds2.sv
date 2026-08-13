// r10svs14 VERIFIER ARM 2 — BOUNDING the k2 regression found in v1v_kinds.sv.
//
// v1v_kinds cell k2 (`input time t`) showed golden modelling the header port as a
// `logic_net` (listed under |vpiNet:) while we model it as a `time_var` (listed
// under |vpiVariables:) — a PRE-EXISTING HOME-VIEW defect that the old dup
// derivation MASKED and § ifaceDupVarsAreHomeVars14 now propagates to the dup.
//
// This arm asks the SAME question of every remaining integral/real kind, so the
// residue is a LIST and not an anecdote.  One interface per kind, each carrying a
// modport and handed WHOLE (bare, dot-free) to a sibling module port.

interface m1_if(input realtime  x); logic d; modport mp(input x, d); endinterface
interface m2_if(input shortreal x); logic d; modport mp(input x, d); endinterface
interface m3_if(input integer   x); logic d; modport mp(input x, d); endinterface
interface m4_if(input longint   x); logic d; modport mp(input x, d); endinterface
interface m5_if(input shortint  x); logic d; modport mp(input x, d); endinterface
interface m6_if(input logic     x); logic d; modport mp(input x, d); endinterface  // control: net
interface m7_if(input int       x); logic d; modport mp(input x, d); endinterface  // control: var
interface m8_if(input real      x); logic d; modport mp(input x, d); endinterface  // control: var

module q1(m1_if.mp p); endmodule
module q2(m2_if.mp p); endmodule
module q3(m3_if.mp p); endmodule
module q4(m4_if.mp p); endmodule
module q5(m5_if.mp p); endmodule
module q6(m6_if.mp p); endmodule
module q7(m7_if.mp p); endmodule
module q8(m8_if.mp p); endmodule

module top;
   realtime  a1; shortreal a2; integer a3; longint a4;
   shortint  a5; logic     a6; int     a7; real    a8;

   m1_if m1(a1); m2_if m2(a2); m3_if m3(a3); m4_if m4(a4);
   m5_if m5(a5); m6_if m6(a6); m7_if m7(a7); m8_if m8(a8);

   q1 y1(m1); q2 y2(m2); q3 y3(m3); q4 y4(m4);
   q5 y5(m5); q6 y6(m6); q7 y7(m7); q8 y8(m8);
endmodule
