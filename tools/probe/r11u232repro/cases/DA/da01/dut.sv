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
  localparam cfg_t C = '{a: 5, f: 1};
endpackage
module child import p::*; #(parameter cfg_t Cfg = '0) (input logic x, output logic y);
  assign y = Cfg.f ? x : 1'b0;
endmodule
module top import p::*; #(parameter cfg_t Cfg = p::C) (input logic x, output logic y);
  child #(.Cfg(Cfg)) u_c (.x(x), .y(y));
endmodule
