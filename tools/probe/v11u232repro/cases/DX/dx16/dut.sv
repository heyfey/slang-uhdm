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
// a typedef alias of the struct
module child import p::*; #(parameter cfg2_t Cfg = '0) (output logic [3:0] y);
  logic [Cfg.a-1:0] w;
  assign w = '1;
  assign y = w;
endmodule
module top(output logic [3:0] y);
  child #(.Cfg(p::C)) u_c (.y(y));
endmodule
