// § nestedCastPlaceholderCaOnly298v
// the cast as a port actual inside the nested module
module leaf (input logic [2:0] x, output logic [2:0] o);
  assign o = x;
endmodule
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    leaf l (.x(T'(b)), .o(z));
  endmodule
  inner u (.b(a), .z(y));
endmodule
