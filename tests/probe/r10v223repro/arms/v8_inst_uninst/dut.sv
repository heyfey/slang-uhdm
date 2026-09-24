// v8 — DEF vs ELAB: the same interface shape, one INSTANTIATED and one not.
package pv8;
  int iv8 = 1;
  string is8 = "i";
  logic [7:0] lv8;
endpackage

interface if_v8_inst;
  import pv8::*;
  logic own_v8a;
endinterface

interface if_v8_uninst;
  import pv8::*;
  logic own_v8b;
endinterface

module top_v8;
  if_v8_inst u_if();
endmodule
