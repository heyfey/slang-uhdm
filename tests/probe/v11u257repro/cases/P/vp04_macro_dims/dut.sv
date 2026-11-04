// § implicitPortTsFirstDim257 (the packed dimensions come from a macro)
`define DIMS [3:0][1:0]
module m(input `DIMS a, output logic o); assign o = a[0][0]; endmodule
module top; logic [3:0][1:0] a; logic o; m u(.a(a), .o(o)); endmodule
