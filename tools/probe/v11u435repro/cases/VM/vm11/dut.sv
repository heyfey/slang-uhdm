// § patMemberSizeCastUbMask435
module dut(input logic a_i, output logic [63:0] b_o);
  typedef struct { logic [63:0] x; logic [63:0] y; } it_t;
  localparam it_t I = '{x: 64'(1), y: 64'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
