// § nestedModArrayScopedName295
module outer(input logic [3:0] a, output logic [3:0] b);
  module inner(input logic x, output logic y); assign y = x; endmodule
  inner u_i [1:0][1:0] (.x(a), .y(b));
endmodule
module top(input logic [3:0] a, output logic [3:0] b);
  outer u_o (.a(a), .b(b));
endmodule
