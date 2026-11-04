// § nestedCastOuterTpPlaceholder298
// two instances where the second written has a smaller name, the outer overridden
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  module inner (input logic [3:0] b, output logic [2:0] z);
    assign z = T'(b);
  endmodule
  inner zz (.b(a), .z(y));
  inner aa (.b(~a), .z(w));
endmodule
module wrap (input logic [3:0] a, output logic [2:0] y, output logic [2:0] w);
  top #(.T(logic [2:0])) t (.a(a), .y(y), .w(w));
endmodule
