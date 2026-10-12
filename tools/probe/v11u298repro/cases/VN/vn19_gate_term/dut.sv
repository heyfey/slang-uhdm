// § nestedCastPlaceholderCaOnly298v
// the cast as a gate-primitive terminal in the nested module
module top #(parameter type T = logic) (input logic [3:0] a, output logic y);
  module inner (input logic [3:0] b, output logic z);
    buf g0 (z, T'(b));
  endmodule
  inner u (.b(a), .z(y));
endmodule
