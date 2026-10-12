// § nestedCastOuterTpPlaceholder298
// the nested module instantiated below another instance
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  module mid (input logic [3:0] c, output logic [2:0] q);
    inner u (.b(c), .z(q));
  endmodule
  mid m (.c(a), .q(y));
endmodule
