// § elabCloneFullNameUnstored137
module dut(input logic [3:0] a, output logic [3:0] b);
  wire [3:0] w = a + 4'd1;
  assign b = w[3:0];
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  dut u(.a(x), .b(y));
endmodule
