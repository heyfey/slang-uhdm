// § nestedCastOuterTpPlaceholder298
// the cast in a function of the nested module
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  module inner (input logic [3:0] b, output logic [2:0] z);
    function automatic logic [2:0] f(input logic [3:0] v); return T'(v); endfunction
    assign z = f(b);
  endmodule
  inner u (.b(a), .z(y));
endmodule
