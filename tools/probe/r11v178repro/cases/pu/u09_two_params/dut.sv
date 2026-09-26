// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  localparam cfg_t C = '{A:B.A, D:B.D + 1};
  localparam int W = C.D;
endpackage
module top; logic [p::W-1:0] q; endmodule
