// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
endpackage
package q;
  import p::*;
  localparam int W = B.D;
endpackage
module top (input logic [q::W-1:0] i, output logic o);
  assign o = i[0];
endmodule
