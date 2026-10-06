// § implicitPortTsFirstDim257 (an implicit-type output and a signed one)
module m(input logic i, output [3:0][1:0] a, input signed [1:0][2:0] b); assign a = {8{i}}; endmodule
module top; logic [3:0][1:0] a; logic i; m u(.a(a), .i(i), .b('0)); endmodule
