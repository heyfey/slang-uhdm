// § implicitPortTsFirstDim257 (two packed dimensions plus an unpacked dimension)
module m(input [3:0][1:0] a [2], output logic o); assign o = a[0][0][0]; endmodule
module top; logic [3:0][1:0] a [2]; logic o; m u(.a(a), .o(o)); endmodule
