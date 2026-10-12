// § nestArrShadowTopKeepsBare295v
module inner(input logic x, output logic y); assign y = ~x; endmodule
module outer(input logic [1:0] a, output logic [1:0] b);
  module inner(input logic x, output logic y); assign y = x; endmodule
  inner u_i [1:0] (.x(a), .y(b));
endmodule
module top(input logic [1:0] a, output logic [1:0] b, c);
  outer u_o (.a(a), .b(b));
  inner u_t (.x(a[0]), .y(c[0]));
  assign c[1] = 1'b0;
endmodule
