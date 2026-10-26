// § patMemberSizeCastUbMask435
package p;
  typedef struct packed { logic [63:0] x; logic [31:0] y; } s_t;
  localparam s_t P = '{x: 64'(7), y: 32'(5)};
endpackage
module dut(input logic a_i, output logic [63:0] b_o);
  import p::*;
  localparam s_t Q = P;
  assign b_o = a_i ? Q.x : P.y;
endmodule
