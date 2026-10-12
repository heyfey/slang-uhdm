// § nestedCastOuterTpPlaceholder298
// the cast in a parameter override of an instance inside the nested module
module leaf #(parameter logic [2:0] P = 0) (output logic [2:0] o);
  assign o = P;
endmodule
module top #(parameter type T = logic [2:0]) (output logic [2:0] y);
  module inner (output logic [2:0] z);
    leaf #(.P(T'(5))) l (.o(z));
  endmodule
  inner u (.z(y));
endmodule
