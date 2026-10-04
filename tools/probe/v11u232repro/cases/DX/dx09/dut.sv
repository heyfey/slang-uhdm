// § defAggParamBindsImportClone232
package p;
  typedef struct { int unsigned a; bit f; } ucfg_t;
endpackage
// an unpacked struct parameter
module child import p::*; #(parameter ucfg_t Cfg = '{a: 1, f: 1}) (input logic x, output logic [Cfg.a-1:0] y);
  assign y = {Cfg.a{x}};
endmodule
module top import p::*; (input logic x, output logic [1:0] y);
  child #(.Cfg('{a: 2, f: 0})) u_c (.x(x), .y(y));
endmodule
