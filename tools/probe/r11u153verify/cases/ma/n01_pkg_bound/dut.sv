// § modArrayBoundRefArrayPath146
package p; parameter int N = 3; endpackage
module sub(input logic a, output logic b); assign b = a; endmodule
module dut(input logic [2:0] a, output logic [2:0] b);
  sub u[p::N-1:0](.a(a), .b(b));
endmodule
