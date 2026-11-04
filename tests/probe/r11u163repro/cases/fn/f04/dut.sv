// § fnParamRangeNetNoFile163
module m(input [3:0] a, output [7:0] z);
  function [7:0] f;
    input [3:0] x;
    localparam L = 8;
    reg [L-1:0] r;
    begin
      r = x;
      f = r;
    end
  endfunction
  assign z = f(a);
endmodule
