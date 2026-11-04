// § patMemberSizeCastSignedInt435
module dut #(parameter int W = 64) (input logic a_i, output logic [W-1:0] b_o);
  localparam type it_t = struct packed { logic [15:0] x; logic [15:0] y; };
  localparam it_t I = '{x: 16'(16'sd5), y: 16'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
