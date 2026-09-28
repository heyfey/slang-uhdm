// § vsStampReducedCtxOnly198v
module top (input logic c, input logic [3:0] p [2][4], input logic [3:0] p1 [4], output logic [3:0] y, output logic [3:0] z);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y = 4'($countones(f(p1[2])));
endmodule
