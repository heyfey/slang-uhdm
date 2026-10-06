// § implicitPortTsFirstDim257 (an implicit-type input with three packed dimensions, parameter bounds)
module m #(parameter int N = 4, parameter int W = 2)(input [N-1:0][W-1:0][1:0] a, output logic o); assign o = a[0][0][0]; endmodule
module top; logic [3:0][1:0][1:0] a; logic o; m u(.a(a), .o(o)); endmodule
