// § nestedCastOuterTpPlaceholder298
// two different nested modules each casting to the outer type parameter
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  module ia (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  module ib (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(~b);
  endmodule
  ia u1 (.b(a), .z(y));
  ib u2 (.b(a), .z(w));
endmodule
