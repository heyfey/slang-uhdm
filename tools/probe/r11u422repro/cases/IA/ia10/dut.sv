// § arrayElemConcatConnWhole422
module child(input [3:0] a, output b);
  assign b = |a;
endmodule
module top(input en, output o);
  child c (.a({4{en}}), .b(o));
endmodule
