// § typedLitElabAdjustLogic427
module sub #(parameter logic [31:0] A = 12'hFFF, parameter logic [7:0] B = 4'h3, parameter bit [15:0] C = 8'hAB, parameter logic [7:0] D = 4'b1010, parameter int E = 8'hAB, parameter int F = 4'b1010, parameter logic [3:0] G = 8'hAB, parameter logic [3:0] H = 8'b1010_1010, parameter logic [7:0] I = 4'HC)(input a, output o);
  assign o = a;
endmodule
module top(input a, output o);
  sub u(.a(a), .o(o));
endmodule
