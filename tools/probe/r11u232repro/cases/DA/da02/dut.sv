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
module top(output logic o);
  import p::*;
  parameter cfg_t TargetCfg = 1;
  assign o = TargetCfg.f;
endmodule
