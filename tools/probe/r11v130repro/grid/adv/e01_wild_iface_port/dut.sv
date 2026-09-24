// § wildcardConnRefSpan130
interface bus; logic d; endinterface
module sub(bus b, input logic clk, output logic q);
  always_ff @(posedge clk) q <= b.d;
endmodule
module top(input logic clk, output logic q);
  bus b();
  sub u(.*);
endmodule
