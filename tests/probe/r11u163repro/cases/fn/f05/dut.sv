// § fnParamRangeNetNoFile163
module m(input [3:0] a, output [7:0] z);
  function [7:0] f;
    parameter L = 4;
    input [L-1:0] x;
    begin
      f = x;
    end
  endfunction
  assign z = f(a);
endmodule
