// § implicitPortTsFirstDim257 (non-ANSI: the direction declaration with two dimensions and a separate logic declaration)
module m(a, o); input [3:0][1:0] a; logic [3:0][1:0] a; output o; logic o; assign o = a[0][0]; endmodule
module top; logic [3:0][1:0] a; logic o; m u(.a(a), .o(o)); endmodule
