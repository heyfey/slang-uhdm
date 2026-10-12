// § nestedCastOuterTpPlaceholder298
// a module nested two levels deep casting to the outermost type parameter
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module mid (input logic [3:0] c, output logic [2:0] q);
    module inner (input logic [3:0] b, output logic [2:0] z);
      assign z = T'(b);
    endmodule
    inner u (.b(c), .z(q));
  endmodule
  mid m (.c(a), .q(y));
endmodule
