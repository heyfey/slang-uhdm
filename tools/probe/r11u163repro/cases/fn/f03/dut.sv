// § fnParamRangeNetNoFile163
module m(input [3:0] a, output [7:0] z);
  function [7:0] f;
    input [3:0] x;
    parameter L = 8;
    reg [L-1:0] r;
    begin
      r = x;
      f = r;
    end
  endfunction
  assign z = f(a);
endmodule
module top(input [3:0] a, output [7:0] z1, z2); m u1(.a(a), .z(z1)); m u2(.a(a), .z(z2)); endmodule
