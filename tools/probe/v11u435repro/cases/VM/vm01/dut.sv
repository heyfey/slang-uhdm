// § patMemberSizeCastUbMask435
module dut(input logic a_i, output logic [63:0] b_o);
  localparam type it_t = struct packed { logic [63:0] x; logic [63:0] y; };
  localparam logic [63:0] K = 64'hFFFF_FFFF_FFFF_FFFF;
  localparam it_t I = '{x: 64'(K), y: 64'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
