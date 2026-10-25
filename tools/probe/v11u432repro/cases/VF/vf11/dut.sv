// § caCallConcatArgFormalTs432
module m(input [5:0] a, output [3:0] y, output [3:0] z);
  function [3:0] f(input [5:0] b);
    f = b[3:0];
  endfunction
  assign y = f({a[2:0], a[5:3]}), z = f({a[5:3], a[2:0]});
endmodule
