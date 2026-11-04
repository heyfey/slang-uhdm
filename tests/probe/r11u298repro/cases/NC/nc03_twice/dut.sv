// § nestedCastOuterTpPlaceholder298
// the nested module instantiated twice
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  inner u1 (.b(a), .z(y));
  inner u2 (.b(~a), .z(w));
endmodule
