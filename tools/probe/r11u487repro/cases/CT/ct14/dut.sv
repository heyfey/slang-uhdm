// § caFoldTsFollowsPa487
module m #(parameter A = 2 + 2) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.A(5)) u(o); endmodule
