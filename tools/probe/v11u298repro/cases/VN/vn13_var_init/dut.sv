// § nestedCastOuterTpPlaceholder298
// the cast in a variable declaration initializer of the nested module
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    logic [2:0] t = T'(4'd5);
    assign z = t ^ b[2:0];
  endmodule
  inner u (.b(a), .z(y));
endmodule
