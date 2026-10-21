// § arrayElemConcatConnWhole422
// the concatenation width equals one element's port width (not sliced)
module child(input [3:0] a, output [3:0] b);
  assign b = a;
endmodule
module top(input [1:0] x, y, output [7:0] o);
  child c[1:0] (.a({x, y}), .b(o));
endmodule
