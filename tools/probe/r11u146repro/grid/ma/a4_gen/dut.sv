// § modArrayBoundRefArrayPath146
module sub(input logic a, output logic b); assign b = a; endmodule
module dut #(parameter int N=2)(input logic [1:0] a, output logic [1:0] b);
  if (1) begin : g
    sub u[N-1:0](.a(a), .b(b));
  end
endmodule
