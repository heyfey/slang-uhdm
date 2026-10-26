// § patMemberSizeCastUbMask435
package p;
  typedef struct packed { logic [31:0] x; logic [31:0] y; } s_t;
  localparam s_t P = '{x: 32'(5), y: 16'(3)};
endpackage
module dut(input logic a_i, output logic [63:0] b_o);
  assign b_o = a_i ? p::P.x : p::P.y;
endmodule
