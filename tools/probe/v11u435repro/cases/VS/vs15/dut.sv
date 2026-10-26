// § patMemberSizeCastSignedInt435
module dut(input logic a_i, output logic [15:0] b_o);
  typedef struct packed { logic [15:0] x; logic [15:0] y; } it_t;
  localparam int K = -3;
  if (1) begin: g
    localparam it_t I = '{x: 16'(K), y: 16'(3)};
    assign b_o = a_i ? I.x : I.y;
  end
endmodule
