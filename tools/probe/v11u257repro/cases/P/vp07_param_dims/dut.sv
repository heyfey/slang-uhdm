// § implicitPortTsFirstDim257 (parameterised packed dimensions on an inout and two ports sharing one declaration)
module m #(parameter int N = 3, parameter int W = 2)(input [N-1:0][W-1:0] a, b, output logic o); assign o = a[0][0] ^ b[1][1]; endmodule
module top; logic [2:0][1:0] a, b; logic o; m u(.a(a), .b(b), .o(o)); endmodule
