// § patMemberSizeCastUbMask435
module dut #(parameter type it_t = struct packed { logic [63:0] x; logic [63:0] y; }, parameter it_t I = '{x: 64'(1), y: 64'(3)}) (input logic a_i, output logic [63:0] b_o);
  assign b_o = a_i ? I.x : I.y;
endmodule
