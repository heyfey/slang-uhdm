// § arrayElemConcatConnWhole422
// a module array inside a generate block with a concatenation connection
module child(input [1:0] a, output [1:0] b);
  assign b = a;
endmodule
module top(input [3:0] x, input [3:0] y, output [7:0] o);
  if (1) begin : g
    child c[3:0] (.a({x, y}), .b(o));
  end
endmodule
