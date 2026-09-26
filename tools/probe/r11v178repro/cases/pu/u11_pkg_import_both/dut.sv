// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  localparam int W = B.D;
endpackage
package q;
  import p::*;
  localparam int V = B.A + W;
endpackage
module top; logic [q::V-1:0] r; endmodule
