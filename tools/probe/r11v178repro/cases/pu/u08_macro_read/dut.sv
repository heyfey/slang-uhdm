// § pkgPatUnqualReadTsNoParent178
`define RD B.D
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  localparam int W = `RD;
endpackage
module top; logic [p::W-1:0] q; endmodule
