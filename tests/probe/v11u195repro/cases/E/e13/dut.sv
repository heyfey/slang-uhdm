// § evalFuncConstReturnBare195v — v11u195 fresh: control of e02: a constant sibling operand of +, every argument constant
module top #(parameter int W = 4) (input logic [7:0] sig, input logic [3:0] w, output logic [3:0] o);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    logic [3:0] r;
    lv = x;
    return 4'd1 + g(lv[1:0]);
  endfunction
  assign o = f(8'hA5);
endmodule
