// § nestedCastPlaceholderCaOnly298v
// a positional port actual cast and a continuous-assignment cast in a nested module instantiated twice
module leaf (input logic [2:0] x, output logic [2:0] o);
  assign o = x;
endmodule
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w, output logic [2:0] v);
  module inner (input logic [3:0] b, output logic [2:0] z, output logic [2:0] q);
    leaf l (T'(b), z);
    assign q = T'(b ^ 4'h3);
  endmodule
  inner u1 (.b(a), .z(y), .q(w));
  inner u2 (.b(~a), .z(v), .q());
endmodule
