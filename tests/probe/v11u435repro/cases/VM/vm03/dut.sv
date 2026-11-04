// § patMemberSizeCastUbMask435
module dut(input logic a_i, output logic [63:0] b_o);
  localparam type it_t = struct packed { logic [63:0] x; logic [63:0] y; };
  typedef enum logic [3:0] {A=1, B=5} e_t;
  localparam it_t I = '{x: 64'(B), y: 64'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
