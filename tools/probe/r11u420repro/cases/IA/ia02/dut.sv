// § arrayBcastConcatActual420
module child(input [1:0] a, output b);
  assign b = a[0];
endmodule
module top(input x, input y, output [3:0] o);
  child c[3:0] (.a({x, y, x, y, x, y, x, y}), .b(o));
endmodule
