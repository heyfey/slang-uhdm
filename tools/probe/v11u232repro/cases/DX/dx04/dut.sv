// § defAggParamBindsImportClone232
package p;
  typedef struct packed { int unsigned a; bit f; } cfg_t;
  typedef cfg_t cfg2_t;
  localparam cfg2_t C = '{a: 4, f: 1};
endpackage
// a typedef alias of the struct; a parameter default reading another parameter
module child import p::*; #(parameter cfg2_t Cfg = '0, parameter cfg2_t Cfg2 = Cfg) (input logic [7:0] x, output logic [7:0] y);
  assign y = x[Cfg2.a-1:0];
endmodule
module top import p::*; (input logic [7:0] x, output logic [7:0] y);
  child #(.Cfg(C)) u_c (.x(x), .y(y));
endmodule
