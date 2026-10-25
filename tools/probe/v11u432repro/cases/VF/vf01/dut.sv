// § caCallConcatArgFormalTs432
module m(input [5:0] a, input [1:0] c, output [3:0] y);
  function [3:0] f(input [1:0] x, input [5:0] b);
    f = b[3:0] ^ {2'b0, x};
  endfunction
  assign y = f(.b({a[2:0], a[5:3]}), .x(c));
endmodule
