// § implicitPortTsFirstDim257 (two packed dimensions separated by a newline and a comment)
module m(input [3:0] /* x */
               [1:0] a, output logic o); assign o = a[0][0]; endmodule
module top; logic [3:0][1:0] a; logic o; m u(.a(a), .o(o)); endmodule
