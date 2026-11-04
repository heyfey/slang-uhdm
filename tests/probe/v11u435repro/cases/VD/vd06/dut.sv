// § patMemberSizeCastUbMask435
package p;
  localparam int unsigned W = 64;
  typedef struct packed { logic [W-1:0] x; logic [W-1:0] y; } s_t;
  localparam s_t P = '{x: W'(1), y: W'(2)};
endpackage
module dut(input logic a_i, output logic [63:0] b_o);
  assign b_o = a_i ? p::P.x : p::P.y;
endmodule
