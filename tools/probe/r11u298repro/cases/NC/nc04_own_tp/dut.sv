// § nestedCastOuterTpPlaceholder298
// control: the nested module's own type parameter (the law must not fire)
module top (input logic [3:0] a, output logic [2:0] y);
  module inner #(parameter type T = logic [2:0]) (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
