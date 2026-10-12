// § nestedModArrayScopedName295
module o1(input logic [1:0] a, output logic [1:0] b);
  module inner(input logic x, output logic y); assign y = x; endmodule
  inner u_i [1:0] (.x(a), .y(b));
endmodule
module o2(input logic [1:0] a, output logic [1:0] b);
  module inner(input logic x, output logic y); assign y = ~x; endmodule
  inner u_i [1:0] (.x(a), .y(b));
endmodule
module top(input logic [1:0] a, output logic [1:0] b, c);
  o1 u1 (.a(a), .b(b));
  o2 u2 (.a(a), .b(c));
endmodule
