// § implicitPortTsFirstDim257 (the dimensions split across lines)
module m(input [3:0]
               [1:0] a, output logic o); assign o = a[0][0]; endmodule
module top; logic [3:0][1:0] a; logic o; m u(.a(a), .o(o)); endmodule
