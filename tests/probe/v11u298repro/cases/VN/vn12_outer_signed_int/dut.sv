// § nestedCastOuterTpPlaceholder298
// an integer-atom default with a signed override from a wrapper
module top #(parameter type T = shortint) (input logic [15:0] a, output logic [15:0] y);
  module inner (input logic [15:0] b, output logic [15:0] z);
    assign z = T'(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
