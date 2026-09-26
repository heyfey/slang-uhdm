// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  typedef logic [B.D-1:0] data_t;
endpackage
module top import p::*; (input data_t i, output logic o);
  assign o = i[0];
endmodule
