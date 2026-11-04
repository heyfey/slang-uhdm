// § nestedCastOuterTpPlaceholder298
// the outer module overridden from a parent
module outer #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
module top (input logic [3:0] a, output logic [2:0] y);
  outer #(.T(logic [1:0])) o (.a(a), .y(y));
endmodule
