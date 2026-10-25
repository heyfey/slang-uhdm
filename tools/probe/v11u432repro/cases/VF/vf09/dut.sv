// § caCallConcatArgFormalTs432
module m(input [5:0] a, output [3:0] y);
  function [3:0] f(input b);
    f = {3'b0, b};
  endfunction
  assign y = f({a[0]});
endmodule
