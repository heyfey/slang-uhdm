// § defAggParamBindsImportClone232
package p;
  typedef struct packed {
    int unsigned a;
    bit f;
  } cfg_t;
  typedef union packed {
    logic [32:0] w;
    cfg_t       c;
  } cu_t;
  typedef cfg_t cfg2_t;
  localparam cfg_t C = '{a: 5, f: 1};
endpackage
// the parameter in a replication count, an indexed part-select width, a part-select bound (constant slots)
module child import p::*; #(parameter cfg_t Cfg = '0) (input logic [15:0] x, output logic [15:0] y);
  logic [15:0] w;
  assign w = {Cfg.a{1'b1}};
  assign y = w;
endmodule
module top(input logic [15:0] x, output logic [15:0] y);
  child #(.Cfg(p::C)) u_c (.x(x), .y(y));
endmodule
