// § callArgVarSelStamp198 § vsStampReducedCtxOnly198v: multi-index select actuals under chains of reducing system calls at depths 2 and 3, and a user call inside a reducing one
module top (input logic [3:0] p [2][4], output logic [3:0] y1, y2, y3);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  function automatic logic [3:0] g(input logic [3:0] x); return x; endfunction
  assign y1 = $signed($unsigned(f(p[1][2])));
  assign y2 = $clog2($signed(f(p[0][1])));
  assign y3 = $unsigned(g(f(p[1][0])));
endmodule
