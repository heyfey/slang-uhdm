// § evalFuncTernaryArm195v — v11u195 fresh: every argument constant, the call in the untaken arm of a ternary on a local
module top(output logic [3:0] o);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    lv = x;
    return lv[0] ? 4'd1 : g(lv[2:1]);
  endfunction
  assign o = f(8'hA5);
endmodule
