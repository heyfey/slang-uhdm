// § nestedCastOuterTpPlaceholder298
// control: a cast in the outer module itself
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = b[2:0];
  endmodule
  inner u (.b(a), .z(y));
  assign w = T'(a);
endmodule
