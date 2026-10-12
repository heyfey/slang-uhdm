// § nestedModArrayScopedName295
module inner(input logic x, output logic y); assign y = x; endmodule
module outer(input logic [1:0] a, output logic [1:0] b, c);
  module inner2(input logic x, output logic y); assign y = x; endmodule
  inner u_t [1:0] (.x(a), .y(b));
  inner2 u_n [1:0] (.x(a), .y(c));
endmodule
module top(input logic [1:0] a, output logic [1:0] b, c);
  outer u_o (.a(a), .b(b), .c(c));
endmodule
