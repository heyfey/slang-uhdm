// § nestedCastOuterTpPlaceholder298
// an int default on the outer type parameter
module top #(parameter type T = int) (input logic [3:0] a, output int y);
  module inner (input logic [3:0] b, output int z);
    assign z = T'(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
