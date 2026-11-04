// § elabBasedLitLowerBase427
module sub #(parameter logic [3:0] A = 4'B10x1, parameter logic [3:0] B = 4'B1010, parameter bit [7:0] C = 8'HAB, parameter int D = 'HFF, parameter logic [7:0] E = 8'hxF, parameter [3:0] F = 4'B1x01, parameter [7:0] G = 'B1x)(input a, output o);
  assign o = a;
endmodule
module top(input a, output o);
  sub u(.a(a), .o(o));
endmodule
