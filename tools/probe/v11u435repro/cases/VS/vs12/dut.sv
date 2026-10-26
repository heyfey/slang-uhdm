// § patMemberSizeCastSignedInt435
module dut(input logic a_i, output logic [31:0] b_o);
  typedef struct packed { logic [15:0] a; logic [15:0] b; } in_t;
  typedef struct packed { in_t i; logic [31:0] y; } it_t;
  localparam int K = -3;
  localparam it_t I = '{i: '{a: 16'(K), b: 16'(2)}, y: 32'(3)};
  assign b_o = a_i ? I.i : I.y;
endmodule
