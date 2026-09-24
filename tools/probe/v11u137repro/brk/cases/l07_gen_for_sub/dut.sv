// § elabCloneFullNameUnstored137
module dut(input logic a, output logic b);
  always_comb b = a;
endmodule
module top(input logic [1:0] x, output logic [1:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    dut u(.a(x[i]), .b(y[i]));
  end
endmodule
