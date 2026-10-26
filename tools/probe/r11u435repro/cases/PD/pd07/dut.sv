// § patMemberSizeCastSignedInt435
package p;
  localparam int K = 9;
  typedef struct packed { logic [63:0] x; logic [63:0] y; } s_t;
  localparam s_t P = '{x: 64'(K), y: 64'(3)};
endpackage
module dut(input logic a_i, output logic [63:0] b_o);
  assign b_o = a_i ? p::P.x : p::P.y;
endmodule
