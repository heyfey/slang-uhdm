// § patMemberSizeCastUbMask435
package p;
  typedef struct packed { logic [63:0] x; logic [63:0] y; } s_t;
  localparam s_t P = '{x: 64'(-1), y: 63'(5)};
endpackage
module dut(input logic a_i, output logic [63:0] b_o);
  assign b_o = a_i ? p::P.x : p::P.y;
endmodule
