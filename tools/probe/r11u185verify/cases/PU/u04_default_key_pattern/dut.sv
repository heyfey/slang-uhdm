// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; int unsigned E; } cfg_t;
  localparam cfg_t B = '{A:2, default:8};
  typedef logic [B.E-1:0] e_t;
  typedef logic [B.A+1:0] a_t;
endpackage
module top import p::*; (input e_t i, output a_t o);
  assign o = i[3:0];
endmodule
