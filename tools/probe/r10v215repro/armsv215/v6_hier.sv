// r10v215 ADVERSARIAL ARM v6 — A HIERARCHICAL REFERENCE THROUGH THE DROPPED
// MODPORT.  ExprEmit.cpp:8612 has a `SymbolKind::Modport` arm in the select
// road; if any of it binds an ACTUAL to the modport OBJECT, dropping the object
// dangles the reference.  Nothing in the implementer's grid reads THROUGH a
// modport in an expression.
interface v6_if;
  logic clk;
  logic frame;
  logic [3:0] data;
  clocking cb @(posedge clk);
    inout frame;
    inout data;
  endclocking
  modport mpc (clocking cb);
  modport mps (input clk, output frame);
endinterface

module v6_reader (v6_if.mps q);
  assign q.frame = q.clk;
endmodule

module top;
  v6_if i1();
  logic seen;
  v6_reader r1(i1);
  always @(posedge i1.clk)
    seen <= i1.mpc.cb.frame;
  initial begin
    @(i1.cb);
    seen = i1.cb.data[0];
  end
endmodule
