// r10v215 ADVERSARIAL ARM v5 — TOP vs NESTED vs NEVER-INSTANTIATED, and the
// interface-inside-an-interface road (R1's shape), each carrying a
// clocking-only modport beside a simple one.  Grid arm B reaches the views but
// only with SIMPLE modports on the inner interface.
interface v5_inner;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input clk, output d);
endinterface

interface v5_outer;
  logic clk;
  logic frame;
  clocking cb2 @(posedge clk);
    inout frame;
  endclocking
  modport ompc (clocking cb2);
  modport omps (input clk);
  v5_inner u_in();
endinterface

// never instantiated anywhere
interface v5_orphan;
  logic clk;
  logic frame;
  clocking cb3 @(posedge clk);
    inout frame;
  endclocking
  modport xmpc (clocking cb3);
endinterface

module v5_sub (v5_inner.mps q);
  assign q.d = q.clk;
endmodule

module top;
  v5_inner i1();
  v5_inner i2();
  v5_outer o1();
  v5_sub s1(i1);
  v5_sub s2(i2);
endmodule
