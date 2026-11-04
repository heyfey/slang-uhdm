// § evalFuncConstReturnBare195v — v11u195 fresh: every argument constant, a second call under an XOR beside the first (the allConst visit claims every call)
module top(output logic [3:0] o);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    lv = x;
    return g(lv[1:0]) + (4'd3 ^ g(lv[5:4]));
  endfunction
  assign o = f(8'hA5);
endmodule
