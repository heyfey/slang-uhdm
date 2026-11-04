// § arrayElemConcatConnWhole422
module child(input a, output b);
  assign b = a;
endmodule
module top(input en, output [3:0] o);
  child c[1:0][1:0] (.a({4{en}}), .b(o));
endmodule
