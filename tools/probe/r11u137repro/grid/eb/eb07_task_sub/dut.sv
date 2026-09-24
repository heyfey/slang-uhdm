// § elabCloneFullNameUnstored137
module dut(input logic a, output logic b);
  task automatic set(output logic q, input logic v);
    q = v;
  endtask
  always_comb set(b, a);
endmodule
module top(input logic x, output logic y);
  dut u(.a(x), .b(y));
endmodule
