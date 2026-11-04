// § patMemberSizeCastSignedInt435
module dut(input logic a_i, output logic [15:0] b_o);
  localparam type it_t = struct packed { logic [15:0] x; logic [15:0] y; };
  localparam int J = 32'hFFFF_FFF0;
  localparam int K = J;
  localparam it_t I = '{x: 16'(K), y: 16'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
