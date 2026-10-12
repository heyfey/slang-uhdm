// § castModTypeParamDefaultTs294
// a cast inside a module function
module top #(parameter type T = logic [7:0]) (input logic [3:0] a, output logic [7:0] y);
  function automatic T f(input logic [3:0] x); return T'(x); endfunction
  assign y = f(a);
endmodule
