// § nestedModGateUpwardNet436
module top(input a, b, output reg y);
module sub;
always @(a or b) y = a ^ b;
endmodule
sub i1();
endmodule
