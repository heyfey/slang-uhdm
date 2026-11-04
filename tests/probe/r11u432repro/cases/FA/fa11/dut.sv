// § caCallConcatArgFormalTs432
module m(input [11:0] op, output [3:0] y);
  wire [3:0] w = f({op[8:6], op[11:9]});
  assign y = w;
  function [3:0] f(input [5:0] b);
    f = b[3:0];
  endfunction
endmodule
