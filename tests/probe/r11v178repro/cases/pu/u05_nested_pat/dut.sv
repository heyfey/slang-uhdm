// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned x; int unsigned y; } in_t;
  typedef struct { in_t A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:'{x:1, y:2}, D:8};
  localparam int W = B.A.x + B.D;
endpackage
module top; logic [p::W-1:0] q; endmodule
