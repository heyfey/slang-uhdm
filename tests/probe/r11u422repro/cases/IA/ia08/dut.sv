// § arrayElemConcatConnWhole422
module child(input a, output b);
  assign b = a;
endmodule
module top(input en, input x, output [3:0] o);
  if (1) begin : g
    child c[3:0] (.a({{2{en}}, x, en}), .b(o));
  end
endmodule
