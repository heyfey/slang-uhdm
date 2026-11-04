// § fnParamRangeNetNoFile163
module sub(input [3:0] a, output [7:0] z);
  function [7:0] f;
    input [3:0] a;
    parameter len = 8;
    parameter half = len/2;
    reg [len-1:0] r;
    reg [half-1:0] h;
    begin h = a; r = {h, h}; f = r; end
  endfunction
  assign z = f(a);
endmodule
module top(input [3:0] a, output [7:0] z);
  sub s(.a(a), .z(z));
endmodule
