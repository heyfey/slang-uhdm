// § elabCloneFullNameUnstored137
module dut(input logic [3:0] a, output logic [3:0] b);
  always_comb begin
    for (int i = 0; i < 4; i++) b[i] = a[3-i];
  end
  initial begin : ib
    int k;
    k = 1;
  end
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  dut u(.a(x), .b(y));
endmodule
