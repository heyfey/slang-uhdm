// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:8};
  localparam int W = $bits(B);
endpackage
module top (input logic [7:0] i, output logic o);
  assign o = i[0];
endmodule
