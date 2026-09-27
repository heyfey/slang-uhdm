// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:9};
  localparam cfg_t C = B;
  localparam int NB = $bits(B);
  localparam int W = B.D;
  typedef logic [W-1:0] w_t;
endpackage
module top import p::*; (input w_t i, output logic [NB-1:0] o);
  assign o = {i, i};
endmodule
