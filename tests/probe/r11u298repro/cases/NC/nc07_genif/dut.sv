// § nestedCastOuterTpPlaceholder298
// the cast in an if-generate of the nested module
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    if (1) begin : g
      assign z = T'(b);
    end
  endmodule
  inner u (.b(a), .z(y));
endmodule
