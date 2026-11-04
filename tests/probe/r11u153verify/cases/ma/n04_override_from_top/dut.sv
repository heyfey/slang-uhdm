// § modArrayBoundRefArrayPath146
module sub(input logic a, output logic b); assign b = a; endmodule
module mid #(parameter int N = 2)(input logic [N-1:0] a, output logic [N-1:0] b);
  sub u[N-1:0](.a(a), .b(b));
endmodule
module dut(input logic [3:0] a, output logic [3:0] b);
  mid #(.N(4)) m(.a(a), .b(b));
endmodule
