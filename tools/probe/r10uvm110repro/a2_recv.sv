// r10uvm110 arm a2 — RECEIVER / HOME / SELECT variety for the dyn-array `new[]`
// lvalue.  Deliberately different naming style from a1 (UPPER/lower/mixed,
// long/short, numbers) so no cell agrees by a uniform-naming accident.
package PK110b;

  typedef byte bq110[];
  typedef struct { bq110 QQ; int w; } strec110;

  class Leaf110;
    int    ee[];
    string ss[];
    Leaf110 sub;
    byte   deep[];
  endclass

  class Mid110;
    Leaf110 L;
    Leaf110 LA[3];
    Leaf110 LQ[$];
    Leaf110 LM[string];
    int     k;
  endclass

  class Top110;
    Mid110 M;
    strec110 R;

    // e01..e08 : deeper chains + varied selects, all `new[]`
    function void deepz(int NN);
      Mid110 mm;
      mm = new();
      mm.L = new();
      mm.L.ee        = new [NN];            // e01 2-dot
      mm.L.sub       = new ();              // e02 2-dot class new (control)
      mm.L.sub.deep  = new [2];             // e03 3-dot
      mm.LA[0].ee    = new [3];             // e04 middle index (literal)
      mm.LA[NN].ss   = new [4];             // e05 middle index (variable)
      mm.LQ[1].ee    = new [5];             // e06 middle queue index
      mm.LM["z"].ee  = new [6];             // e07 middle assoc index
      mm.k           = NN;                  // e08 scalar (control)
    endfunction

    // e09..e12 : loop / conditional homes
    function void homez(int MM);
      Mid110 q1;
      q1 = new(); q1.L = new();
      for (int i = 0; i < 2; i++) q1.L.ee = new [i];   // e09 for-loop body
      if (MM > 0) q1.L.ss = new [MM];                  // e10 if branch
      else        q1.L.ee = new [1];                   // e11 else branch
      while (MM < 0) begin q1.L.deep = new [2]; MM++; end // e12 while body
    endfunction

    // e13..e15 : STRUCT receiver (not a class handle)
    function void strz();
      strec110 sr;
      sr.QQ = new [7];                     // e13 struct member, new[]
      sr.w  = 1;                           // e14 struct member, plain
      R.QQ  = new [8];                     // e15 class-prop struct member
    endfunction
  endclass
endpackage

interface if110b;
  logic clk;
  byte  IB[];
endinterface

module mod110b(if110b P);
  import PK110b::*;
  strec110 MS;
  Leaf110  ML;
  int      mz;
  initial begin
    ML = new();
    mz = 2;
    MS.QQ   = new [mz];      // e16 module struct member new[]
    P.IB    = new [3];       // e17 INTERFACE-PORT member new[]
    ML.ee   = new [4];       // e18 module class-handle member new[]
    ML.ee[0] = 9;            // e19 element write (control)
    MS.w    = 5;             // e20 module struct scalar (control)
  end
endmodule

module top110b;
  if110b W();
  mod110b U(.P(W));
endmodule
