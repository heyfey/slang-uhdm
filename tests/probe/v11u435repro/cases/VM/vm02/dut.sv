// § patMemberSizeCastUbMask435
module dut(input logic a_i, output logic [64:0] b_o);
  localparam type it_t = struct packed { logic [64:0] x; logic [64:0] y; };
  localparam it_t I = '{x: 65'(-1), y: 65'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
