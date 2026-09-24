// r10svs10 arm c1 — THE DECISIVE SPLIT.
//
// The producer (src/ModuleEmit.cpp ~883) already carries a law: a class-handle
// def net keeps its ref_typespec ONLY when the handle is never procedurally
// assigned ("bar = new() strips it — OneThis vs OneClass").  Those two goldens
// are BOTH `module top` (OneThis: assigned, stripped; OneClass: unassigned,
// kept).  r10svs9's b5 arm found golden KEEPING the link on an ASSIGNED handle
// in a `program`.  So the written-strip is real for SOME shape and wrong for
// another, and there are TWO candidate discriminators that OneThis/b5 confound:
//
//   (i)  the SCOPE KIND        — module vs program vs interface
//   (ii) TOP-NESS of the def   — OneThis's `top` is a TOP module (def == top,
//                                single-view); SVSwitch's `testcase` is a
//                                NON-TOP program instantiated by top.sv:44.
//
// This arm crosses them so neither can hide behind the other.  Every scope gets
// an ASSIGNED handle and a NEVER-ASSIGNED control, so each cell carries its own
// baseline and a scope that simply never emits the link is distinguishable from
// one that strips on assignment.
class K;
  int x;
  function new(int v = 0); x = v; endfunction
endclass

// ---- TOP module (the OneThis shape) ----
module mtop;
  K a1;                 // a1 TOP module,      ASSIGNED
  K a2;                 // a2 TOP module,      never assigned (control)
  initial a1 = new();
endmodule

// ---- NON-TOP module, instantiated ----
module msub;
  K b1;                 // b1 non-top module,  ASSIGNED
  K b2;                 // b2 non-top module,  never assigned (control)
  initial b1 = new();
endmodule

// ---- NON-TOP program, instantiated (the SVSwitch shape) ----
program psub;
  K c1;                 // c1 non-top program, ASSIGNED
  K c2;                 // c2 non-top program, never assigned (control)
  initial c1 = new();
endprogram

// ---- TOP program, never instantiated ----
program ptop;
  K d1;                 // d1 top program,     ASSIGNED
  K d2;                 // d2 top program,     never assigned (control)
  initial d1 = new();
endprogram

// ---- NON-TOP interface, instantiated ----
interface isub;
  K e1;                 // e1 interface,       ASSIGNED
  K e2;                 // e2 interface,       never assigned (control)
  initial e1 = new();
endinterface

module holder;
  msub u_m();
  psub u_p();
  isub u_i();
endmodule
