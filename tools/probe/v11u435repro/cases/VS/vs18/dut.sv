// § patMemberSizeCastSignedInt435
interface ifc;
  typedef struct packed { logic [15:0] x; logic [15:0] y; } it_t;
  localparam int K = -3;
  localparam it_t I = '{x: 16'(K), y: 16'(3)};
  logic [15:0] v;
  assign v = I.x;
endinterface
module dut(output logic [15:0] b_o);
  ifc u();
  assign b_o = u.v;
endmodule
