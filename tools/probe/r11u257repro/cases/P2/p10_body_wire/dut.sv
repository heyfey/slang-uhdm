// § implicitPortTsFirstDim257 (control: a module-body wire with two packed dimensions)
module m(input logic i, output logic o); wire [3:0][1:0] w = {8{i}}; assign o = w[0][0]; endmodule
module top; logic i; logic o; m u(.i(i), .o(o)); endmodule
