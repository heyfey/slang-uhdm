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
module child import p::*; #(parameter cfg_t Cfg = '0) (output logic [3:0] y);
  assign y = Cfg.a[1:0] + Cfg.a[Cfg.a[1:0] +: 2];
endmodule
module top(output logic [3:0] y);
  child #(.Cfg(p::C)) u_c (.y(y));
endmodule
