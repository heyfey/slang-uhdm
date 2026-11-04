// § nestedCastOuterTpPlaceholder298
// a cast in a module nested in a module, the outer's localparam type
module top (input logic [3:0] a, output logic [2:0] y);
  localparam type T = logic [2:0];
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
