// § nestedCastOuterTpPlaceholder298
// the outer type parameter also typing the outer port
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output T y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b) + 1'b1;
  endmodule
  inner u (.b(a), .z(y));
endmodule
