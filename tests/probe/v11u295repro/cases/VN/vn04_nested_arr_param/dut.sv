// § nestedModArrayScopedName295
module outer(input logic [1:0] a, output logic [1:0] b);
  module inner #(parameter int W = 1)(input logic x, output logic y); assign y = x; endmodule
  inner #(.W(3)) u_i [1:0] (.x(a), .y(b));
endmodule
module top(input logic [1:0] a, output logic [1:0] b);
  outer u_o (.a(a), .b(b));
endmodule
