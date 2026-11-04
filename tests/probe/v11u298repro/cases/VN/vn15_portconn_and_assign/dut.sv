// § nestedCastPlaceholderCaOnly298v
// a port actual cast written before a continuous-assignment cast in the nested module
module leaf (input logic [2:0] x, output logic [2:0] o);
  assign o = x;
endmodule
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  module inner (input logic [3:0] b, output logic [2:0] z, output logic [2:0] q);
    leaf l (.x(T'(b)), .o(z));
    assign q = T'(~b);
  endmodule
  inner u (.b(a), .z(y), .q(w));
endmodule
