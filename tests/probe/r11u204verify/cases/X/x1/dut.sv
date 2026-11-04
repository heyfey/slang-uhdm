// § callArgVarSelStamp198 § evalFuncOmittedDefaultKeepsCall196 § evalFuncCastMemberKeepsCall191: calls with a multi-index select actual that omit a read default, or whose body casts; and constant calls kept by each law
module top (input logic [3:0] p [2][4], output logic [3:0] y1, y2, y3, y4);
  typedef logic [3:0] n_t;
  function automatic logic [3:0] f(input logic [3:0] x, input int b = 1); return x + b; endfunction
  function automatic logic [3:0] g(input logic [3:0] x); return n_t'(x); endfunction
  assign y1 = f(p[1][2]);
  assign y2 = g(p[0][1]);
  assign y3 = f(4'h3);
  assign y4 = g(4'h3);
endmodule
