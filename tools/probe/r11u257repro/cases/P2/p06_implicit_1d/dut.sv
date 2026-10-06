// § implicitPortTsFirstDim257 (control: an implicit-type input with one packed dimension)
module m(input [3:0] a, output logic o); assign o = a[0]; endmodule
module top; logic [3:0] a; logic o; m u(.a(a), .o(o)); endmodule
