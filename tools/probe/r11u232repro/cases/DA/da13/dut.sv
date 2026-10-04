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
module top import p::*; #(parameter cfg_t A = '0, parameter cfg_t B = p::C) (output logic o);
  assign o = A.f | B.f;
endmodule
