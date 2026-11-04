// § evalFuncTernaryArm195v — v11u195 fresh: the call in an arm of a local-bit condition, an assignment
module top #(parameter int W = 4) (input logic [7:0] sig, input logic [3:0] w, output logic [3:0] o);
  localparam int LP = 3;
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    logic [3:0] r;
    lv = x;
    r = lv[0] ? g(lv[2:1]) : 4'd0;
    return r;
  endfunction
  assign o = f(sig);
endmodule
