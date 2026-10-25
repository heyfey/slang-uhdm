// § caCallConcatArgFormalTs432
module m(input [5:0] a, output [3:0] y);
  function [3:0] f(input int b);
    f = b[3:0];
  endfunction
  assign y = f({a[2:0], a[5:3]});
endmodule
