// § nestedCastOuterTpPlaceholder298
// the outer module casts to T too, written before the nested instance
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  assign w = T'(a);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
