// § ppBasedLitWsAfter166
module sub(input [7:0] d, output [7:0] q); assign q = d; endmodule
module top(output [7:0] q);
  sub u(.d(8'h 1), .q(q));
endmodule
