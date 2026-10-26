// § patMemberSizeCastUbMask435
module dut #(parameter int W = 64) (input logic a_i, output logic [W-1:0] b_o);
  localparam type it_t = struct packed { logic [64:0] x; logic [7:0] y; };
  localparam it_t I = '{x: 65'(3), y: 8'(1)};
  assign b_o = a_i ? I.x : I.y;
endmodule
