// § nestedCastOuterTpPlaceholder298
// the cast as an operand of an addition and inside a concatenation
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [5:0] w);
  module inner (input logic [3:0] b, output logic [2:0] z, output logic [5:0] q);
    assign z = T'(b) + 3'd1;
    assign q = {T'(b), T'(~b)};
  endmodule
  inner u (.b(a), .z(y), .q(w));
endmodule
