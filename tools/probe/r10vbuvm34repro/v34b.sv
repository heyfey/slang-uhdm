// r10vbuvm34repro/v34b.sv — VERIFIER ARM B: the BINDING face.
// The patch sets `lv` to an int_var BEFORE every resolved arm, which also
// changes `declLoopVar`'s RETURN in a NON-package home: the tail gate
// registers int_var / array_var / assocIdx / res22 only, so a scoped cell
// that used to produce a string_var / class_var / bit_var in a module,
// interface or program home now REGISTERS and its body references bind.
// Every cell here USES the loop variable in a distinct expression POSITION,
// and every cell has an UNUSED twin.  MEASUREMENT ONLY.
package qb34;
  class kb34; int k; endclass
  class cb34;
    typedef cb34 this_type;
    static int      sa34 [string];    // assoc[string]  -> pristine string_var
    static int      sk34 [kb34];      // assoc[class]   -> pristine class_var
    static bit [7:0] sv34;            // packed vector  -> pristine int_var
    static string   sq34 [$];         // queue<string>  -> pristine array_var
    static int      sf34 [4];
  endclass
  function automatic int fb34(int x); return x; endfunction
endpackage

module mb34;
  import qb34::*;
  int    r34;
  int    arr34 [8];
  string t34;
  int    cc34;
  initial begin
    // --- scoped, loop var USED, one position per cell -------------------
    foreach (cb34::sa34[i]) r34 = fb34(1);              // U0 unused
    foreach (cb34::sa34[i]) t34 = i;                    // U1 rhs of assign
    foreach (cb34::sk34[i]) cc34 = fb34(1);             // U2 unused (class idx)
    foreach (cb34::sv34[i]) r34 = i;                    // U3 rhs, packed vec
    foreach (cb34::sq34[i]) r34 = i;                    // U4 rhs, queue<string>
    foreach (cb34::sf34[i]) arr34[i] = 1;               // U5 LHS index
    foreach (cb34::sf34[i]) r34 = fb34(i);              // U6 call argument
    foreach (cb34::sf34[i]) if (i > 0) r34 = 1;         // U7 condition
    foreach (cb34::sf34[i]) r34 = {i, i};               // U8 concat member
    foreach (cb34::sf34[i]) r34 = i + r34;              // U9 binary operand
    // --- bare controls ---------------------------------------------------
    foreach (arr34[i]) r34 = i;                         // C1 module var, bare
    foreach (arr34[i]) arr34[i] = 1;                    // C2
  end
endmodule

interface ib34;
  import qb34::*;
  int r34;
  function void ifn34();
    foreach (cb34::sa34[i]) r34 = 1;                    // I1 interface, scoped
    foreach (cb34::sf34[i]) r34 = i;                    // I2 interface, used
  endfunction
endinterface

program pb34;
  import qb34::*;
  int r34;
  initial begin
    foreach (cb34::sa34[i]) r34 = 1;                    // P1 program, scoped
    foreach (cb34::sf34[i]) r34 = i;                    // P2 program, used
  end
endprogram

module topb34;
  mb34 u1();
  mb34 u2();
  mb34 u3();
  ib34 iu();
endmodule
