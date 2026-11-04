// § patMemberSizeCastUbMask435
module dut #(parameter int W = 64) (input logic a_i, output logic [W-1:0] b_o);
  localparam type it_t = struct packed { logic [W-1:0] x; logic [W-1:0] y; };
  localparam it_t I = '{x: W'(1'b1), y: W'(8'hA5)};
  assign b_o = a_i ? I.x : I.y;
endmodule
