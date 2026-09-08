// r10uvm215 GRID ARM B — THE VIEW CONJUNCT.  The same clocking-only modport
// (and its simple-port control) reached through each way an interface_inst can
// appear: the design's def listing, an elaborated instance, an interface that
// is NEVER instantiated (def listing only), an interface instantiated TWICE,
// and an interface instantiated inside ANOTHER interface.
//
// b1 instantiated once  (def + elab)
// b2 never instantiated (def only)
// b3 instantiated twice (def + two elab views)
// b4 instantiated INSIDE another interface

interface b1_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input d);
endinterface

interface b2_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input d);
endinterface

interface b3_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input d);
endinterface

interface b4_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input d);
endinterface

interface b4_outer_if;
  logic clk;
  b4_if inner();
  modport mpc2 (input clk);
endinterface

module top;
  b1_if u1();
  b3_if u3a();
  b3_if u3b();
  b4_outer_if u4();
endmodule
