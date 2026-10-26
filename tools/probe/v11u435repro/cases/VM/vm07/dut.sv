// § patMemberSizeCastUbMask435
module dut(input logic a_i, output logic [63:0] b_o);
  localparam type it_t = struct packed { logic [63:0] x; logic [63:0] y; };
  localparam logic [7:0] K = 8'hFF;
  localparam it_t I = '{x: 64'(K + 1), y: 64'(K)};
  assign b_o = a_i ? I.x : I.y;
endmodule
