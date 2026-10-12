// § nestedCastPlaceholderCaOnly298v
// a cast as a port actual of the nested instance itself in the outer module, and a nested-module port actual
module leaf (input logic [2:0] x, output logic [2:0] o);
  assign o = x;
endmodule
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  module inner (input logic [2:0] b, output logic [2:0] z);
    leaf l2 (.x(T'(b + 3'd1)), .o(z));
  endmodule
  inner u (.b(T'(a)), .z(y));
  assign w = '0;
endmodule
