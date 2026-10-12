// § nestedCastOuterTpPlaceholder298
// the outer type parameter declared in the module body (parameter type in the body)
module top (input logic [3:0] a, output logic [2:0] y);
  parameter type T = logic [2:0];
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
