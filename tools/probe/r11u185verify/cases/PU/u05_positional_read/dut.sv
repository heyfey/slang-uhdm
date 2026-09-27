// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{3, 7};
  localparam cfg_t C = '{A:1, D:5};
  typedef logic [B.D-1:0] b_t;
  typedef logic [C.D-1:0] c_t;
endpackage
module top import p::*; (input b_t i, output c_t o);
  assign o = i[4:0];
endmodule
