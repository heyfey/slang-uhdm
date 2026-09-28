// § callArgVarSelStamp198 § vsStampReducedCtxOnly198v: non-reducing contexts at depth 2 and 3 ($countones under a user call under $signed, $bits of the call, $countones over $signed)
module top (input logic [3:0] p [2][4], output logic [3:0] y1, y2, y3);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  function automatic logic [3:0] g(input logic [3:0] x); return x; endfunction
  assign y1 = $signed(g($countones(f(p[1][2]))));
  assign y2 = $bits(f(p[1][2]));
  assign y3 = $countones($signed(f(p[0][0])));
endmodule
