// § nestedCastOuterTpPlaceholder298
// the nested module instantiated only in an if-generate
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  if (1) begin : g
    inner ug (.b(a), .z(y));
  end
endmodule
