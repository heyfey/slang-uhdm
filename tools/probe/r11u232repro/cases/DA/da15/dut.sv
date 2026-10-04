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
module child import p::*; #(parameter cfg_t Cfg = '0, parameter int N = Cfg.a) (output logic [N-1:0] y);
  assign y = {N{Cfg.f}};
endmodule
module top(output logic [4:0] y);
  child #(.Cfg(p::C)) u_c (.y(y));
endmodule
