// § patMemberSizeCastUbMask435
module dut(input logic a_i, output logic [63:0] b_o);
  localparam type it_t = struct packed { logic [63:0] x; logic [63:0] y; };
  localparam it_t I = '{x: 64'(1'b1), y: 64'(4'hF)};
  assign b_o = a_i ? I.x : I.y;
endmodule
