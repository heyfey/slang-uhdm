// § caCallConcatArgFormalTs432
module m(input [11:0] op, output [3:0] y);
  assign y = f({3'd1, 3'd2});
  function [3:0] f(input [5:0] b);
    f = b[3:0];
  endfunction
endmodule
