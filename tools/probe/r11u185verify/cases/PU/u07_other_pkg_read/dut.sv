// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:4};
  function automatic int f(); return B.A; endfunction
endpackage
package q;
  import p::*;
  localparam int W2 = B.D;
endpackage
module top import q::*; (output logic [W2-1:0] o);
  assign o = p::f();
endmodule
