// § patMemberSizeCastUbMask435
typedef struct packed { logic [63:0] x; logic [63:0] y; } it_t;
class C;
  localparam it_t I = '{x: 64'(1), y: 64'(3)};
endclass
module dut(input logic a_i, output logic [63:0] b_o);
  assign b_o = a_i ? C::I.x : C::I.y;
endmodule
