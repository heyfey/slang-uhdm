// § elabUnszXzTypedAdjust427
module sub #(parameter logic [7:0] A = 4'hx, parameter logic [7:0] B = 12'h1x0, parameter logic [7:0] C = 8'hx1, parameter int D = 8'h1x, parameter bit [15:0] E = 4'hx, parameter [7:0] F = 4'hx, parameter [7:0] G = 12'h1x0, parameter logic [7:0] H = 12'b1x0)(input a, output o);
  assign o = a;
endmodule
module top(input a, output o);
  sub u(.a(a), .o(o));
endmodule
