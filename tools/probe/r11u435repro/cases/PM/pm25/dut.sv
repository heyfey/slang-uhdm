// § patMemberSizeCastUbMask435
package p;
  typedef struct packed { logic [63:0] x; logic [15:0] y; } s_t;
  localparam s_t P = '{x: 64'(5), y: 16'(5)};
endpackage
module dut(input logic a_i, output logic [63:0] b_o);
  import p::*;
  assign b_o = a_i ? P.x : P.y;
endmodule
