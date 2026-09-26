// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  localparam int W = B.D;
endpackage
module top; logic [p::B.A-1:0] q; logic [p::W-1:0] r; endmodule
