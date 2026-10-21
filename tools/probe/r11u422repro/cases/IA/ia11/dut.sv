// § arrayElemConcatConnWhole422
module child(input a, output b);
  assign b = a;
endmodule
module top(input en, input x, output [3:0] o);
  child c[3:0] (.a({en, x, en, x}), .b({o[3:2], o[1:0]}));
endmodule
