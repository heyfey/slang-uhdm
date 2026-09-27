// § pkgPatUnqualReadTsNoParent178
package p;
  typedef struct { int unsigned A; int unsigned D; } cfg_t;
  localparam cfg_t B = '{A:2, D:6};
  logic [B.D-1:0] arr [B.A];
endpackage
module top import p::*; (output logic [5:0] o);
  assign o = arr[1];
endmodule
