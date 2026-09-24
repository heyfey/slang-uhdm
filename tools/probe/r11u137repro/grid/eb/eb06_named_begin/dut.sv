// § elabCloneFullNameUnstored137
module dut(input logic a, output logic b);
  always_comb begin : blk
    logic t;
    t = a;
    b = t;
  end
endmodule
module top(input logic x, output logic y);
  dut d(.a(x), .b(y));
endmodule
