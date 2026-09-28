// § evalFuncTernaryArm195v — v11u195 fresh: the call in an arm of a ternary whose condition reads the non-constant local
module top(input logic [7:0] sig, output logic [3:0] o);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    lv = x;
    return lv[0] ? g(lv[2:1]) : 4'd0;
  endfunction
  assign o = f(sig);
endmodule
