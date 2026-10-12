// § nestedCastOuterTpPlaceholder298
// two casts in one nested module, one instance
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  module inner (input logic [3:0] b, output logic [2:0] z, output logic [2:0] q);
    assign z = T'(b);
    assign q = T'(~b);
  endmodule
  inner u (.b(a), .z(y), .q(w));
endmodule
