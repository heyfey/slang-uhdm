// § implicitPortTsFirstDim257 (a localparam written with two packed dimensions and no type keyword)
module m(output logic o); localparam [3:0][1:0] L = 8'h5a; assign o = L[1][0]; endmodule
module top; logic o; m u(.o(o)); endmodule
