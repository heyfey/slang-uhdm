// § defAggParamBindsImportClone232
package p;
  typedef struct packed { int unsigned a; bit f; } cfg_t;
endpackage
// two instances with different overrides, one defaulted
module child import p::*; #(parameter cfg_t Cfg = '{a: 1, f: 1}) (input logic x, output logic y);
  assign y = Cfg.f ? x : 1'b0;
endmodule
module top import p::*; (input logic x, output logic y, output logic z);
  child #(.Cfg('{a: 3, f: 0})) u1 (.x(x), .y(y));
  child u2 (.x(x), .y(z));
endmodule
