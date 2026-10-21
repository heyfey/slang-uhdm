// § caWholeSysCallSharesDefCell428
module m #(parameter W = 4) (input [W-1:0] x, output [7:0] y);
  assign y = $bits(x);
  wire [7:0] w = $clog2(x);
endmodule
module top(input [5:0] a, output [7:0] b);
  m #(.W(6)) u(a, b);
endmodule
