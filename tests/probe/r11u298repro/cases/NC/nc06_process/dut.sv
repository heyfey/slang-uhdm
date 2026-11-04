// § nestedCastOuterTpPlaceholder298
// the cast in an always_comb of the nested module
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    always_comb z = T'(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
