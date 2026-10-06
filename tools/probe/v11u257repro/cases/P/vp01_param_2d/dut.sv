// § implicitPortTsFirstDim257 (a module parameter written with two packed dimensions and no type keyword)
module m #(parameter [3:0][1:0] P = '0)(output logic o); assign o = P[0][0]; endmodule
module top; logic o; m u(.o(o)); endmodule
