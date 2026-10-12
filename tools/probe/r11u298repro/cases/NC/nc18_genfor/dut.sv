// § nestedCastOuterTpPlaceholder298
// the nested module instantiated in a for-generate
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y [2]);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  for (genvar i = 0; i < 2; i++) begin : g
    inner u (.b(a), .z(y[i]));
  end
endmodule
