// § elabCloneFullNameUnstored137
module dut(input logic a, output logic b);
  assign b = ~a;
endmodule
module top(input logic x, output logic y, output logic z);
  dut u1(.a(x), .b(y));
  dut u2(.a(x), .b(z));
endmodule
