// § implicitPortTsFirstDim257 (an input wire with two packed dimensions)
module m(input wire [3:0][1:0] a, output logic o); assign o = a[0][0]; endmodule
module top; logic [3:0][1:0] a; logic o; m u(.a(a), .o(o)); endmodule
