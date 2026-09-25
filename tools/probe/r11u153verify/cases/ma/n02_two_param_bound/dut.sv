// § modArrayBoundRefArrayPath146
module sub(input logic a, output logic b); assign b = a; endmodule
module dut #(parameter int A = 1, parameter int B = 2)(input logic [1:0] a, output logic [1:0] b);
  sub u[A+B-1:A](.a(a), .b(b));
endmodule
