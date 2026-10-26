// § patMemberSizeCastSignedInt435
module dut #(parameter int W = 64) (input logic a_i, output logic [W-1:0] b_o);
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  localparam int K = -3;
  localparam it_t I = '{x: 8'(K), y: 8'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
