// § vsStampReducedCtxOnly198v
module top (input logic c, input logic [3:0] p [2][4], input logic [3:0] p1 [4], output logic [3:0] y, output logic [3:0] z, output logic [3:0] yy [2]);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  function automatic logic [3:0] g(input logic [3:0] x); return x ^ 4'h5; endfunction
  assign y = $clog2(f(p[1][2]));
endmodule
