// § patMemberSizeCastUbMask435
interface ifc;
  typedef struct packed { logic [63:0] x; logic [63:0] y; } it_t;
  localparam it_t I = '{x: 64'(1), y: 64'(3)};
  logic [63:0] v;
  assign v = I.x;
endinterface
module dut(output logic [63:0] b_o);
  ifc u();
  assign b_o = u.v;
endmodule
