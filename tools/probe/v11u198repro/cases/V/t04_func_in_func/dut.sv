// § callArgVarSelStamp198
module top (input logic c, input logic [3:0] p [2][4], input logic [3:0] pp [2][2][2], input logic [3:0] p1 [4], output logic [3:0] y, output logic [3:0] y2 [2][4], output logic [3:0] z);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  function automatic logic [3:0] g(input logic [3:0] x [2][4]); return f(x[1][2]); endfunction
  assign y = g(p);
endmodule
