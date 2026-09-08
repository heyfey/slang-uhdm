// r10v215 ADVERSARIAL ARM v3 — AN IMPORT-ONLY MODPORT AS A PORT QUALIFIER.
// Grid arm A proves golden mints nothing for `modport (import t)` in the DEF
// listing; grid arm C only ever qualifies a port with a CLOCKING-only modport.
// A tf-only modport reaching the port-binding road (modportsByDef lookup at
// ModuleEmit.cpp ~9107 / ~20904, and the port view's fallback) is untested.
interface v3_if;
  logic clk;
  logic d;
  task automatic tk(input logic a);
  endtask
  modport mpi (import tk);
  modport mps (input clk, output d);
endinterface

module v3_sub_i (v3_if.mpi p);
  initial p.tk(1'b0);
endmodule

module v3_sub_s (v3_if.mps q);
  assign q.d = q.clk;
endmodule

module top;
  v3_if i1();
  v3_if i2();
  v3_sub_i s1(i1);
  v3_sub_s s2(i2);
endmodule
