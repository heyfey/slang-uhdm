// § patMemberSizeCastUbMask435
module dut #(parameter int W = 64) (input logic a_i, output logic [W-1:0] b_o);
  localparam type it_t = struct packed { logic [31:0] x; logic [31:0] y; };
  localparam int K = 9;
  localparam it_t I = '{x: 32'(-1), y: 32'(-K)};
  assign b_o = a_i ? I.x : I.y;
endmodule
