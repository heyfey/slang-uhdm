// § arrayElemConcatConnWhole422
module child(input [1:0] a, output b);
  assign b = a[1] ^ a[0];
endmodule
module top(input x, input y, output [1:0] o);
  child c[1:0] (.a({x, y}), .b(o));
endmodule
