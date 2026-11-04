// § patMemberSizeCastSignedInt435
module dut(input logic a_i, output logic [15:0] b_o);
  localparam type it_t = struct packed { logic [15:0] x; logic [15:0] y; };
  localparam int K = -3;
  localparam it_t I = '{default: 16'(K)};
  assign b_o = a_i ? I.x : I.y;
endmodule
