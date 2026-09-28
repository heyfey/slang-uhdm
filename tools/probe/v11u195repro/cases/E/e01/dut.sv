// § evalFuncOperandKinds195v — v11u195 fresh: a part-select sibling operand of + (reduceExpr's constantOperands check rejects a part_select operand), non-constant call
module top(input logic [7:0] sig, output logic [3:0] o);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    lv = x;
    return lv[7:6] + g(lv[1:0]);
  endfunction
  assign o = f(sig);
endmodule
