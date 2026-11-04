// § implicitPortTsFirstDim257 (signed before two packed dimensions)
module m(input signed [3:0][1:0] a, output logic o); assign o = a[0][0]; endmodule
module top; logic [3:0][1:0] a; logic o; m u(.a(a), .o(o)); endmodule
