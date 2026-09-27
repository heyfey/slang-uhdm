// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned x; int unsigned y; } in_t;
  typedef struct { in_t inner; int unsigned d; } cfg_t;
  localparam cfg_t B = '{inner:'{x:3, y:4}, d:8};
  localparam int W = B.inner.y;
  typedef logic [B.d-1:0] word_t;
endpackage
module top import p::*; (input word_t i, output logic [W-1:0] o);
  assign o = i[W-1:0];
endmodule
