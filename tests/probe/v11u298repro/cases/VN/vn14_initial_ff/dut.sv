// § nestedCastOuterTpPlaceholder298
// the cast in an always_ff and an initial block of the nested module
module top #(parameter type T = logic [2:0]) (input logic clk, input logic [3:0] a, output logic [2:0] y);
  module inner (input logic c, input logic [3:0] b, output logic [2:0] z);
    always_ff @(posedge c) z <= T'(b);
    initial z = T'(4'd1);
  endmodule
  inner u (.c(clk), .b(a), .z(y));
endmodule
