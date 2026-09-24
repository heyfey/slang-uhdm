// § elabCloneFullNameUnstored137
module dut #(parameter int W = 4)(input logic [W-1:0] a, output logic [W-1:0] b);
  localparam int H = W / 2;
  always_comb b = a + H;
endmodule
module top(input logic [3:0] x, output logic [3:0] y, output logic [7:0] z);
  dut u1(.a(x), .b(y));
  dut #(.W(8)) u2(.a({x, x}), .b(z));
endmodule
