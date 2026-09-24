// r10v215 ADVERSARIAL ARM v7 — MULTIPLICITY 1, 2 AND 3.  The brief's
// "x 1-3 instances" face: an interface whose ONLY modport is clocking-only,
// instantiated once, twice and three times in one design, beside a control
// interface whose modport survives.  A law that mints per-INSTANCE rather than
// per-DEFINITION shows up here as an asymmetric count.
interface v7_a;              // one clocking-only modport, ONE instance
  logic clk;
  logic frame;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
endinterface

interface v7_b;              // same, TWO instances
  logic clk;
  logic frame;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
endinterface

interface v7_c;              // same, THREE instances
  logic clk;
  logic frame;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
endinterface

interface v7_ctl;            // the control: a SIMPLE modport, three instances
  logic clk;
  logic d;
  modport mps (input clk, output d);
endinterface

module top;
  v7_a a1();
  v7_b b1();
  v7_b b2();
  v7_c c1();
  v7_c c2();
  v7_c c3();
  v7_ctl k1();
  v7_ctl k2();
  v7_ctl k3();
endmodule
