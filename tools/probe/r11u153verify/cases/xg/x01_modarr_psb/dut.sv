// § psBoundBareRefByBase145 § modArrayBoundRefArrayPath146
module sub(input logic [1:0] a, output logic [1:0] b); assign b = a; endmodule
module dut #(parameter int N = 2)(input logic [7:0] a, output logic [3:0] b);
  localparam int H = 5;
  localparam int L = 2;
  sub u[N-1:0](.a(a[H:L]), .b(b));
endmodule
