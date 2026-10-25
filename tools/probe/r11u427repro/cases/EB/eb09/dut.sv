// § elabUnszXzTypedAdjust427
module sub #(parameter logic [7:0] A = 'b1x, parameter logic [7:0] B = 'b0x1, parameter logic [7:0] C = 'bx1, parameter logic [7:0] D = 'b11x, parameter [7:0] E = 'b0x1, parameter [7:0] F = 'bx1, parameter [7:0] G = 'b11x, parameter int H = 'b1x, parameter I = 'b1x, parameter logic [7:0] J = 'hx1, parameter logic [7:0] K = 'h1x)(input a, output o);
  assign o = a;
endmodule
module top(input a, output o);
  sub u(.a(a), .o(o));
endmodule
