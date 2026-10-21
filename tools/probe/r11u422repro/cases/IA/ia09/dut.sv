// § arrayElemConcatConnWhole422
module child(input a, output b);
  assign b = a;
endmodule
module top(input en, input x, input y, output [3:0] o);
  child c[3:0] (.a({{2{x}}, y, en}), .b(o));
endmodule
