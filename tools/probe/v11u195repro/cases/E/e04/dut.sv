// § evalFuncTernaryArm195v — v11u195 fresh: the call in the untaken arm of a constant-condition ternary
module top #(parameter int W = 4) (input logic [7:0] sig, output logic [3:0] o);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    lv = x;
    return (W > 2) ? 4'd0 : g(lv[1:0]);
  endfunction
  assign o = f(sig);
endmodule
