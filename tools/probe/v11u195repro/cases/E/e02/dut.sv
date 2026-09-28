// § evalFuncConstReturnBare195v — v11u195 fresh: a part-select sibling operand of +, every argument constant
module top(output logic [3:0] o);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    lv = x;
    return lv[7:6] + g(lv[1:0]);
  endfunction
  assign o = f(8'hA5);
endmodule
