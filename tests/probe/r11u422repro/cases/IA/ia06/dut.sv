// § arrayElemConcatConnWhole422
module child(input a, output b);
  assign b = a;
endmodule
module top(input [1:0] x, input y, output [2:0] o);
  child c[2:0] (.a({x[0], y, x[1]}), .b(o));
endmodule
