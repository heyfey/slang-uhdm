// § arrayElemConcatConnWhole422
module child(input a, output b);
  assign b = a;
endmodule
module top(input en, output [3:0] o);
  child c[3:0] ({4{en}}, o);
endmodule
