// § patMemberSizeCastSignedInt435
module dut(input logic a_i, output logic [39:0] b_o);
  localparam type it_t = struct packed { logic [39:0] x; logic [39:0] y; };
  localparam int K = 32'hFFFF_FFF0;
  localparam it_t I = '{x: 40'(K), y: 40'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
