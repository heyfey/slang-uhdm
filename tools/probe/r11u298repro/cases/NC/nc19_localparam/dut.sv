// § nestedCastOuterTpPlaceholder298
// constant slot: the cast in a nested module's localparam initializer
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    localparam logic [2:0] K = T'(5);
    assign z = b[2:0] ^ K;
  endmodule
  inner u (.b(a), .z(y));
endmodule
