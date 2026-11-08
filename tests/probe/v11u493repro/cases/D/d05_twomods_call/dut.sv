// § enumCastChainKeepsInnerCast493
module mb(input logic [7:0] a, output logic [7:0] y);
  localparam int W = 8;
  function automatic logic [7:0] g(logic [7:0] s);
    return s;
  endfunction
  assign y = W'(W'(g(a)));
endmodule
module ma(input logic [3:0] a, output logic [3:0] y);
  localparam int W = 4;
  function automatic logic [3:0] g(logic [3:0] s);
    return s;
  endfunction
  assign y = W'(W'(g(a)));
endmodule
module top(input logic [3:0] a4, input logic [7:0] a8, output logic [3:0] y4, output logic [7:0] y8);
  mb ub(a8, y8);
  ma ua(a4, y4);
endmodule
