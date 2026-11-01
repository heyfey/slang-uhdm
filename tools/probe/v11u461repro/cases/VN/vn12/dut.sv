// § pkgNestedAnonAggMemberInst461
package p;
  typedef struct packed { union packed { logic [3:0] a; bit [3:0] b; } u; bit [3:0] y; } s_t;
  parameter s_t P = 8'h5a;
endpackage
module top;
  import p::*;
  logic [7:0] q;
  assign q = P;
endmodule
