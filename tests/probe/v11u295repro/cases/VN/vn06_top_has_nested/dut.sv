// § nestedModArrayScopedName295
module top(input logic [1:0] a, output logic [1:0] b);
  module inner(input logic x, output logic y); assign y = x; endmodule
  inner u_i [1:0] (.x(a), .y(b));
endmodule
