// § elabCloneFullNameUnstored137
module dut(input logic a, output logic b);
  always_comb begin
    b = a;
  end
endmodule
module top(input logic x, output logic y);
  dut u_dut(.a(x), .b(y));
endmodule
