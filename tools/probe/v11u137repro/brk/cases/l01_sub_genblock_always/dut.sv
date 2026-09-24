// § elabCloneFullNameUnstored137
module dut(input logic a, output logic b);
  if (1) begin : g
    logic t;
    always_comb begin
      t = a;
    end
    assign b = t;
  end
endmodule
module top(input logic x, output logic y1, y2);
  dut u1(.a(x), .b(y1));
  dut u2(.a(x), .b(y2));
endmodule
