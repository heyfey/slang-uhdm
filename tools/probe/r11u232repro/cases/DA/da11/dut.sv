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
module child import p::*; #(parameter cfg_t Cfg = '{a: 2, f: 0}) (output logic [4:0] y);
  assign y = {Cfg.f, Cfg.a};
endmodule
module top(output logic [4:0] y1, output logic [4:0] y2);
  child u_1 (.y(y1));
  child #(.Cfg('{a: 7, f: 1})) u_2 (.y(y2));
endmodule
