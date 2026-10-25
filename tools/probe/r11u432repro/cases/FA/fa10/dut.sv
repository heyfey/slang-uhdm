// § caCallConcatArgFormalTs432
module m(input [11:0] op, output [3:0] y);
  assign y = f({2{op[2:0]}});
  function [3:0] f(input [5:0] b);
    f = b[3:0];
  endfunction
endmodule
