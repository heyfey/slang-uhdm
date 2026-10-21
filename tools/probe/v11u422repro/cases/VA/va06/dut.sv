// § arrayElemConcatConnWhole422
// a module array of a parameterized child with an output concatenation
module child #(parameter W = 1) (input [W-1:0] a, output [W-1:0] b);
  assign b = a;
endmodule
module top(input [7:0] i, output [3:0] hi, lo);
  child #(.W(2)) c[3:0] (.a(i), .b({hi, lo}));
endmodule
