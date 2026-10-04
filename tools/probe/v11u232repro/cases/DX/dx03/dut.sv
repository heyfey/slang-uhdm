// § defAggParamBindsImportClone232
package p;
  typedef struct packed { int unsigned a; bit f; } cfg_t;
endpackage
// an explicit import in the body, an uninstantiated second definition
module child (input logic x, output logic y);
  import p::cfg_t;
  parameter cfg_t Cfg = '0;
  assign y = Cfg.f ? x : 1'b0;
endmodule
module lone import p::*; #(parameter cfg_t Cfg = '{a: 2, f: 0}) (output logic [Cfg.a-1:0] y);
  assign y = '0;
endmodule
module top import p::*; (input logic x, output logic y);
  child #(.Cfg('{a: 3, f: 1})) u_c (.x(x), .y(y));
endmodule
