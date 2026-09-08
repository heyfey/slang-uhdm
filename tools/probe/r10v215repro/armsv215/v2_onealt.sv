// r10v215 ADVERSARIAL ARM v2 — THE FALLBACK AT N=1.
// The port-view conjunct was measured at N=2 surviving modports (grid c6) and
// at N=0 (grid c1).  N=1 — a port qualified by a clocking-only modport in an
// interface that mints EXACTLY ONE other modport — is the cell that separates
// "list every minted modport" from "list the single remaining one by accident".
// v2a: port on the clocking-only modport, one simple modport survives.
// v2b: control, the same interface with the port on the SIMPLE modport.
interface v2_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input clk, output d);
endinterface

module v2_sub_c (v2_if.mpc p);
endmodule

module v2_sub_s (v2_if.mps q);
  assign q.d = q.clk;
endmodule

module top;
  v2_if i1();
  v2_if i2();
  v2_sub_c s1(i1);
  v2_sub_s s2(i2);
endmodule
