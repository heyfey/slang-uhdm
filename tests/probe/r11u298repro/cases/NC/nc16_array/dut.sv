// § nestedCastOuterTpPlaceholder298
// an instance array of the nested module
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y [2]);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  inner u [2] (.b(a), .z(y));
endmodule
