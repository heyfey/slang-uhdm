// § patMemberSizeCastSignedInt435
module dut(input logic a_i, output logic [31:0] b_o);
  typedef struct packed { logic [31:0] x; logic [31:0] y; } it_t;
  class C;
    localparam int K = -7;
    localparam it_t I = '{x: 32'(K), y: 32'(3)};
  endclass
  assign b_o = a_i ? C::I.x : C::I.y;
endmodule
