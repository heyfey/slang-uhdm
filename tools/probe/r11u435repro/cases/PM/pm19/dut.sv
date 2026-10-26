// § patMemberSizeCastUbMask435
module dut #(parameter int W = 64) (input logic a_i, output logic [W-1:0] b_o);
  localparam type it_t = struct packed { logic [63:0] x; logic [63:0] y; };
  localparam bit [7:0] KU = 8'd9;
  localparam it_t I = '{x: 64'(KU), y: 64'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
