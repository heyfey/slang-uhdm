// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
endpackage
package q;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:3, D:9};
  localparam int W = B.D;
endpackage
module top; logic [q::W-1:0] r; logic [p::B.D-1:0] s; endmodule
