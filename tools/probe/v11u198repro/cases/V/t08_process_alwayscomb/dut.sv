// § callArgVarSelStamp198
module top (input logic c, input logic [3:0] p [2][4], input logic [3:0] pp [2][2][2], input logic [3:0] p1 [4], output logic [3:0] y, output logic [3:0] y2 [2][4], output logic [3:0] z);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  always_comb z = f(p[1][1]);
  assign y = f(p[0][0]) | f(p1[2]);
endmodule
