// § modArrayBoundRefArrayPath146
module sub(input logic a, output logic b); assign b = a; endmodule
module dut #(parameter int N=2, parameter int L=0)(input logic [1:0] a, output logic [1:0] b);
  sub u[L:N-1](.a(a), .b(b));
endmodule
