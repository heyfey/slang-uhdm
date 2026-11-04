// § nestedCastOuterTpPlaceholder298
// a plain instance written before an if-generate instance
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  inner u (.b(~a), .z(w));
  if (1) begin : g
    inner ug (.b(a), .z(y));
  end
endmodule
