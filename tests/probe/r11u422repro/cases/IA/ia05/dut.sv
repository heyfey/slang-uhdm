// § arrayElemConcatConnWhole422
module child(input a, output b);
  assign b = a;
endmodule
module top #(parameter N = 4) (input en, output [N-1:0] o);
  child c[N-1:0] (.a({N{en}}), .b(o));
endmodule
