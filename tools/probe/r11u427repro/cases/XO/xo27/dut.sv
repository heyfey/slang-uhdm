// § xzOvLitKeepsText427
module leaf #(parameter P = 2'b00)(input a, output o); assign o = a ^ P[0]; endmodule
module mid #(parameter Q = 2'b00)(input a, output [1:0] o);
  leaf #(.P(2'bx1)) l1(.a(a), .o(o[0]));
  leaf #(.P(Q)) l2(.a(a), .o(o[1]));
endmodule
module top(input a, output [1:0] o);
  mid #(.Q(2'b1z)) m(.a(a), .o(o));
endmodule
