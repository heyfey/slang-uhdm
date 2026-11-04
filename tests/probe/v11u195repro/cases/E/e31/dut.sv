// § evalFuncTernaryArm195v — v11u195 fresh: the call in the taken left arm of a module-parameter condition
module top #(parameter int W = 4) (input logic [7:0] sig, input logic [3:0] w, output logic [3:0] o);
  localparam int LP = 3;
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [7:0] lv;
    logic [3:0] r;
    lv = x;
    return (W > 2) ? g(lv[1:0]) : 4'd0;
  endfunction
  assign o = f(sig);
endmodule
