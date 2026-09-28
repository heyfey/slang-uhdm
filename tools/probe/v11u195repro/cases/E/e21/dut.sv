// § evalFuncExecCallArgTs191 — v11u195 fresh: every argument constant: a whole-right-side call on a local's part select
module top #(parameter int W = 4) (input logic [7:0] sig, input logic [3:0] w, output logic [3:0] o);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    logic [3:0] r;
    lv = x;
    r = g(lv[1:0]);
    return r;
  endfunction
  assign o = f(8'hA5);
endmodule
