// § patMemberSizeCastUbMask435
package p;
  typedef struct packed { logic [64:0] x; logic [7:0] y; } s_t;
  localparam s_t P = '{x: 65'(3), y: 8'(1)};
endpackage
module dut(input logic a_i, output logic [63:0] b_o);
  assign b_o = a_i ? p::P.x : p::P.y;
endmodule
