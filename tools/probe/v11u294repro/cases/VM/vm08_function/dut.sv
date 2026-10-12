// § castModTypeParamDefaultTs294
// a cast inside a module function and task
module top #(parameter type T = logic [2:0]) (input logic [3:0] a, output logic [2:0] y);
  function automatic logic [2:0] f(logic [3:0] v); return T'(v); endfunction
  assign y = f(a);
endmodule
