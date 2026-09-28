// § evalFuncOperandKinds195v — v11u195 fresh: a formal as the sibling operand of +, and an indexed part select sibling
module top(input logic [7:0] sig, output logic [3:0] o, output logic [3:0] o2);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [3:0] v, input logic [7:0] x);
    logic [7:0] lv;
    lv = x;
    return v + g(lv[1:0]);
  endfunction
  function automatic logic [3:0] h(input logic [7:0] x);
    logic [7:0] lv;
    lv = x;
    return lv[2+:2] + g(lv[5:4]);
  endfunction
  assign o = f(sig[3:0], sig);
  assign o2 = h(sig);
endmodule
