// r10v215 ADVERSARIAL ARM v4 — INTERFACE INSTANCE ARRAYS.
// The whole-array port road (ModuleEmit.cpp ~9530+, `conn.first->kind ==
// SymbolKind::InstanceArray`) emits a per-element modport port view through the
// SAME emitInterfaceInstance/connModport path the law's fallback now sits in.
// No grid arm instantiates an interface array at all.
interface v4_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input clk, output d);
endinterface

module v4_sub_c (v4_if.mpc p);
endmodule

module v4_sub_s (v4_if.mps q);
  assign q.d = q.clk;
endmodule

module v4_arr_c (v4_if.mpc p[2]);
endmodule

module top;
  v4_if ia[2]();
  v4_if ib[2]();
  v4_sub_c e0(ia[0]);
  v4_sub_s e1(ia[1]);
  v4_arr_c aw(ib);
endmodule
