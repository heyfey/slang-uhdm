// § patMemberSizeCastSignedInt435
module dut(input logic a_i, output logic [7:0] b_o);
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  localparam logic signed [3:0] K = 4'b1101;
  localparam it_t I = '{x: 8'(K), y: 8'(3)};
  assign b_o = a_i ? I.x : I.y;
endmodule
