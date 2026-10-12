// § nestedCastOuterTpPlaceholder298
// the cast as a ternary branch and under a unary operator
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, input logic s, output logic [2:0] y, output logic [2:0] w);
  module inner (input logic [3:0] b, input logic c, output logic [2:0] z, output logic [2:0] q);
    assign z = c ? T'(b) : 3'd0;
    assign q = ~T'(b);
  endmodule
  inner u (.b(a), .c(s), .z(y), .q(w));
endmodule
