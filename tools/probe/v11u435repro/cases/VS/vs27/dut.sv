// § patMemberSizeCastSignedInt435
module dut(input logic a_i, output logic [15:0] b_o);
  localparam type it_t = struct packed { logic [15:0] x; logic [15:0] y; };
  localparam int K = 32'd4294967293;
  localparam it_t I = '{x: 40'(K), y: 40'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
