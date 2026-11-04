// § caCallConcatArgFormalTs432
module m(input [11:0] op, output [3:0] y);
  assign y = g(op[3:0], {op[5:4], op[7:6]});
  function [3:0] g(input [3:0] a, input [3:0] b);
    g = a ^ b;
  endfunction
endmodule
