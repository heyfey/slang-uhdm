// § evalFuncConstVisitGate195v — v11u195 fresh: every argument constant, an assignment whose second call sits in a part-select-sibling operation
module top (output logic [3:0] o);
  function automatic logic [3:0] g(input logic [1:0] d);
    return {2'b00, d};
  endfunction
  function automatic logic [3:0] f(input logic [7:0] x);
    logic [3:0] r;
    r = g(x[1:0]) + (x[7:4] + g(x[5:4]));
    return r;
  endfunction
  assign o = f(8'hA5);
endmodule
