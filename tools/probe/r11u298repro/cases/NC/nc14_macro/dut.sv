// § nestedCastOuterTpPlaceholder298
// the cast written through a macro
`define CST(x) T'(x)
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = `CST(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
