// § nestedCastOuterTpPlaceholder298
// the cast in a net declaration assignment of the nested module
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    wire [2:0] t = T'(b);
    assign z = t;
  endmodule
  inner u (.b(a), .z(y));
endmodule
